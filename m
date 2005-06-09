From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: Fix link failure in 5701
Date: Thu, 09 Jun 2005 15:55:52 -0700
Message-ID: <1118357752.5838.13.camel@rh4>
References: <1118086942.5008.14.camel@rh4>
 <20050609232830.GC12434@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, peterc@gelato.unsw.edu.au, netdev@oss.sgi.com,
        netdev@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Grant Grundler" <iod00d@hp.com>
In-Reply-To: <20050609232830.GC12434@esmail.cup.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-06-09 at 16:28 -0700, Grant Grundler wrote:

> Michael, David,
> I confirmed this patch in fact fixes the problem on currently
> shipping rx7620 and rx8620 "Core LAN" cards. I expected it would
> but now have nice warm fuzzies that it really 100% does.

Thanks for testing, Grant.

> 
> One minor issue: I unloaded the unpatched tg3 v3.29 driver and
> then did not get a link when loaded the patched tg3 v3.30 driver.
> Unplugging and replugging the cable made this work.
> v3.30 continued to work fine after a reboot.
> 

This is odd. May be the link partner is in a bad state when previously
connected to unpatched tg3, and requires unplug to get out of that
state.
