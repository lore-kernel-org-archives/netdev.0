From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe RLT-8139 related)
Date: Tue, 3 Aug 2004 18:50:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803185026.A10580@electric-eye.fr.zoreil.com>
References: <20040803003515.A29885@electric-eye.fr.zoreil.com> <Pine.LNX.4.44.0408031523220.32102-100000@silmu.st.jyu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org,
        netdev@oss.sgi.com, brad@brad-x.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0408031523220.32102-100000@silmu.st.jyu.fi>; from ptsjohol@cc.jyu.fi on Tue, Aug 03, 2004 at 03:32:15PM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pasi Sjoholm <ptsjohol@cc.jyu.fi> :
[...]
> The first log file is with both patchs applied and the second one with one 
> little change to rx8139_rx() to show if it even goes to through 
> 
> "        while (netif_running(dev) && received < budget
>                && (RTL_R8 (ChipCmd) & RxBufEmpty) == 0) {"-section.
> 
> This was the change which I made.. so you can see in the second log file 
> that there won't be any of these messages after the driver has crashed. 

If you remove the "if (received > 0) {" test in r8139-10.patch and keep
both patches applied, I assume you are back to a crash within 15min (instead
of within 2min as suggested by the log), right ?

--
Ueimor
