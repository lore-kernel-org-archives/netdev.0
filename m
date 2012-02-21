From: hayeswang <hayeswang@realtek.com>
Subject: RE: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Tue, 21 Feb 2012 10:58:55 +0800
Message-ID: <39C5DD558BB9499FB0D7CA7AEF943376@realtek.com.tw>
References: <20120215163748.GA3998@elliptictech.com> <1329333239.2469.3.camel@edumazet-laptop> <20120215232303.GB31463@electric-eye.fr.zoreil.com> <33249D172FBD4AE09E24D4F24E973BD9@realtek.com.tw> <20120216074637.GA6208@electric-eye.fr.zoreil.com> <20120216120448.GB9504@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0003_01CCF087.CE0D6FA0"
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	'Nick Bowler' <nbowler@elliptictech.com>,
	<netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:59627 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761Ab2BUC7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 21:59:11 -0500
In-Reply-To: <20120216120448.GB9504@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_0003_01CCF087.CE0D6FA0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Thursday, February 16, 2012 8:05 PM
> To: Hayeswang
> Cc: 'Eric Dumazet'; 'Nick Bowler'; netdev@vger.kernel.org
> Subject: Re: Bogus frames transmitted with r8169 & 
> fragmentation & large mtu
> 
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> > I am testing it now.
> 
> It does not fix the problem. It seems to make a difference but I still
> see a few percents packet loss. The pattern has changed a bit 
> too: there
> are more bogus IP fragment offsets.
> 
> Trying with 'ping -qf -c 100 -l 2 -s 65507 10.0.7.1'

It works fine for me. I use Linux platform (Fedora 16 with kernel 3.2.0 with
that patch) with the realtek nic to ping Windows platform with the NVIDIA nic,
and I connect the two PCs directly without the switch. It works well except for
the first packet after I set the new mtu.

> 
> So far I have only seen it with the 2nd and last fragment.
> 
 
Best Regards,
Hayes

------=_NextPart_000_0003_01CCF087.CE0D6FA0
Content-Type: application/octet-stream; name="ping.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="ping.log"

[   45.415894] r8169 0000:04:00.0: eth0: RTL8168d/8111d at 0xf7e58000, =
00:e0:4c:68:00:04, XID 083000c0 IRQ 46=0A=
p33p1     Link encap:Ethernet  HWaddr 00:E0:4C:68:00:04  =0A=
          inet addr:192.168.94.44  Bcast:192.168.94.255  =
Mask:255.255.255.0=0A=
          inet6 addr: fe80::2e0:4cff:fe68:4/64 Scope:Link=0A=
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1=0A=
          RX packets:3714 errors:0 dropped:0 overruns:0 frame:0=0A=
          TX packets:3670 errors:0 dropped:0 overruns:0 carrier:0=0A=
          collisions:0 txqueuelen:1000 =0A=
          RX bytes:28794250 (27.4 MiB)  TX bytes:28919110 (27.5 MiB)=0A=
          Interrupt:46 Base address:0x8000 =0A=
PING 192.168.94.20 (192.168.94.20) 65507(65535) bytes of data.=0A=
=0A=
--- 192.168.94.20 ping statistics ---=0A=
100 packets transmitted, 100 received, 0% packet loss, time 89ms=0A=
rtt min/avg/max/mdev =3D 1.368/1.643/1.954/0.099 ms, pipe 2, ipg/ewma =
0.904/1.705 ms=0A=
PING 192.168.94.20 (192.168.94.20) 65507(65535) bytes of data.=0A=
=0A=
--- 192.168.94.20 ping statistics ---=0A=
100 packets transmitted, 100 received, 0% packet loss, time 90ms=0A=
rtt min/avg/max/mdev =3D 1.419/1.658/1.943/0.078 ms, pipe 2, ipg/ewma =
0.912/1.673 ms=0A=
Linux fc16.localdomain 3.2.0 #1 SMP Tue Jan 10 16:11:29 CST 2012 i686 =
i686 i386 GNU/Linux=0A=

------=_NextPart_000_0003_01CCF087.CE0D6FA0--
