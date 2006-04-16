From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 locks up in 2.6.16.5
Date: Sun, 16 Apr 2006 21:53:27 +0200
Message-ID: <20060416195327.GA14173@electric-eye.fr.zoreil.com>
References: <20060415204716.GA1755@jupiter.toms.net> <20060416005821.GA9821@electric-eye.fr.zoreil.com> <20060416134201.GA2681@jupiter.toms.net> <20060416144354.GA11433@electric-eye.fr.zoreil.com> <20060416172639.GA12243@jupiter.toms.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:22171 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750734AbWDPT5h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 15:57:37 -0400
To: "Thomas A. Oehser" <tom@toms.net>
Content-Disposition: inline
In-Reply-To: <20060416172639.GA12243@jupiter.toms.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas A. Oehser <tom@toms.net> :
[...]
> > I'll welcome a complete dmesg after you have recovered through
> > ifconfig down/up though.
> 
> _Nothing_ on dmesg.

Huh... Nothing appears when you issue 'dmesg' ?

[...]
> eth1      Link encap:Ethernet  HWaddr 00:E0:4C:13:A9:56  
>           inet addr:192.168.99.99  Bcast:192.168.99.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:528416 errors:252 dropped:620 overruns:0 frame:966
>           TX packets:243040 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           Interrupt:161 Base address:0xe000 

How much long was the card under load ? A few seconds ?
The same 1500 bytes mtu is used everywhere and the issue can not be
reproduced with a simple ping -f -q -l 64 -s what_you_want aimed at
the 8169, right ?

[...]
> What next?

ethtool -d/-S before and after failure, .config and /proc/interrupts.

-- 
Ueimor
