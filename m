From: Marcello <voloterreno@tin.it>
Subject: Re: NAPI 8139too.c for 2.4.23
Date: Mon, 01 Dec 2003 23:54:50 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3FCBC6BA.3090106@tin.it>
References: <20031201205038.GK10711@ovh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Octave <oles@ovh.net>
In-Reply-To: <20031201205038.GK10711@ovh.net>
List-Id: netdev.vger.kernel.org

Octave ha scritto:

>Stephen,
>I get your patch from http://lwn.net/Articles/54815/ for 2.6.X and 
>I rewrote it for 2.4.23. Tested with 2.4.23 on high load servers. I 
>have no more "Too much work at interrupt".                                     
>
>I dropped it on ftp://ftp.ovh.net/made-in-ovh/8139too.c-2.4-0.9.27
>
>Hope it helps.
>Octave
>
>before:  
>-------  
># ps auxw
>root       256  0.0  0.0     0    0 ?        SW   Nov28   0:00 [eth0]
># ifconfig
>          RX packets:40940899 errors:250542 dropped:7052 overruns:250542 frame:0
>          TX packets:33057049 errors:0 dropped:0 overruns:20 carrier:0
># dmesg
>eth0: Setting 100mbps full-duplex based on auto-negotiated partner ability 41e1.
>nfs: server X.X.X.X not responding, still trying
>nfs: server X.X.X.X OK
>eth0: Too much work at interrupt, IntrStatus=0x0040.
>
>with NAPI
>---------
>          RX packets:428253 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:357949 errors:0 dropped:0 overruns:0 carrier:0
>8139too Fast Ethernet driver 0.9.27
>PCI: Found IRQ 11 for device 00:0b.0
>eth0: RealTek RTL8139 at 0xec00, 00:e0:4c:91:03:b0, IRQ 11
>eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-net" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>
Sorry , my happiness was a bit premature :D

This doesn't recognize with autonegotiation the Speed correctly .

My ethernet device is connected to an ethernet ADSL Router , speed 
10Mbit/HD , but the autonegotiation recongnize 10Mbit/FD , and this 
makes the connection very slow , because of the very much errors , but 
the strange thing is that ifconfig doesn't reports any error (but , of 
course, I know that there are as with the previous driver ) , for 
ifconfig all is OK , but my connection is veeeeery slow .

Forcing the 10MBps/HD with MII-TOOL makes my connection the same as ever .

Bye

Marcello


