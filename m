From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH] net: ftgmac100: Request clock and set speed
Date: Thu, 12 Oct 2017 11:02:10 +0800
Message-ID: <CACPK8Xd6CPfXJ3UnfCJxRPYq7CYXSt=2uS9N8sVt60e04GuB2w@mail.gmail.com>
References: <20171010044925.21078-1-joel@jms.id.au> <1507623269.25065.202.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andrew Jeffery <andrew@aj.id.au>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507623269.25065.202.camel@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2017 at 4:14 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Tue, 2017-10-10 at 15:19 +1030, Joel Stanley wrote:
>> According to the ASPEED datasheet, gigabit speeds require a clock of
>> 100MHz or higher. Other speeds require 25MHz or higher.
>
> Did you try "live" changing by either using ethtool or plugging into
> switches/hubs at different speed ?
>
> Also this is aspeed'isms, we should probably keep that under an
> is_aspeed test.
>
> My assumption is that we wouldn't bother, and just leave the freq
> set based on whether there's a physical gigabit capable connection or
> not (ie, real gigabit PHY vs. NC-SI really). But if it can help save a
> few milliwatts..

I didn't try changing the link speed at runtime. I don't have a setup
that lets me precisely measure power consumption, so it's hard to know
what the benefits are. In the future I can revisit this and do those
measurements.

I'll change it to be as you suggest; 100MHz for PHY and 50MHz for NC-SI.

Cheers,

Joel
