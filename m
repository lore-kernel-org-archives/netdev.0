From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip: Poll link status more frequently for Comet chips
Date: Sat, 21 Jun 2014 19:22:18 -0700 (PDT)
Message-ID: <20140621.192218.1801115154664681697.davem@davemloft.net>
References: <1403382541-7129-1-git-send-email-linux@rainbow-software.org>
	<CAP6odjjE3hYXPggagPvF+hYm7nGHQqLqeQ3Ls9jzd=DVBLcJ4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, grundler@parisc-linux.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: grantgrundler@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP6odjjE3hYXPggagPvF+hYm7nGHQqLqeQ3Ls9jzd=DVBLcJ4w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grantgrundler@gmail.com>
Date: Sat, 21 Jun 2014 15:59:30 -0700

> Hi Ondrej,
> 
> On Sat, Jun 21, 2014 at 1:29 PM, Ondrej Zary <linux@rainbow-software.org> wrote:
>> Poll link status every 2 seconds instead of 60 for ADMtek Comet chips.
> 
> Why use 2 seconds for the polling interval?
> 
> I'm sure you have a good reason for this and it should be in the
> commit message or as a comment in the code.
> 
> I otherwise have no objection to this change.

Agreed, please post this with a better commit message, specifically
make sure you explain why the interval is being changed and why
2*HZ is specifically being choosen.

Thanks.
