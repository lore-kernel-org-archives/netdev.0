From: Sascha Schumann <sascha@schumann.cx>
Subject: Re: 2.4.21: bug report for tg3:  tx lockup when changing MTU
Date: Sat, 2 Aug 2003 11:44:43 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0308021122290.27834@eco.foo>
References: <3F2AEFBF.3040604@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F2AEFBF.3040604@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Kernel is 2.4.21 + custom patches (which should not affect tg3).
>
> lspci says the NIC is: Altima AC9100 (rev 15)

    [1] says that the AC9100 based Netgear GA302T cards don't
    support jumbo frames.  I'm seeing regular lockups once
    packets larger than 1500bytes flow through the NIC.

    It would be cool though if this turned out to be a driver
    limitation and not a (crippled) chipset issue.

    [1] http://www.google.de/search?q=cache:y_kVF_dR3TkJ:www.lanshop.co.uk/html/ga302tq.htm+netgear+ga302t+jumbo+frames&hl=de&ie=UTF-8

    - Sascha
