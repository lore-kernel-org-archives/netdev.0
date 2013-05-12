From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC 17/42] drivers/net/ethernet/renesas: don't check resource
 with devm_ioremap_resource
Date: Sun, 12 May 2013 19:26:19 +0400
Message-ID: <518FB49B.7030708@cogentembedded.com>
References: <1368173847-5661-1-git-send-email-wsa@the-dreams.de> <1368173847-5661-18-git-send-email-wsa@the-dreams.de> <518EAB9B.8040106@cogentembedded.com> <20130512094202.GA3039@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130512094202.GA3039@katana>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12-05-2013 13:42, Wolfram Sang wrote:

>> You should really compile-test your patches.

> Easier said than done with a cleanup series touching various platforms
> and architectures. If there are already solutions how to find a .config
> compiling the source file modified, I am all ears.

    You can always try to do:

$ make drivers/net/ethernet/renesas/sh_eth.o

with a .config file you have. It will compile a file regardless of 
whether it's enabled in your .config or not...

> That being said, the actual mistake I did was embarassing, I agree. I am
> sorry for that and will improve. And, doing things means doing mistakes,
> too.

    Be more attentive in the future please. :-)

> Regards,

>     Wolfram

WBR, Sergei
