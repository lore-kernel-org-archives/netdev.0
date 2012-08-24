From: =?ISO-8859-1?Q?An=EDbal_Almeida_Pinto?= <anibal.pinto@efacec.com>
Subject: Gianfar ethernet drop package
Date: Fri, 24 Aug 2012 17:14:38 +0100
Message-ID: <5037A86E.2000004@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.efacec.com ([62.28.144.243]:15085 "HELO mail2.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753481Ab2HXQ1J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 12:27:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have an board with a ppc with a 8379, kernel 3.0.39 and with a Gianfa=
r=20
Ethernet Controller Version 1.2.

When connect the board to office network the number of dropped packets=20
reported by ifconfig continues to increase.

=46ollowing the test made at [1] I use tcpdump and when running it the=20
number of drop packages don't have increased.

When executing ethtool eth0 -S it return a rx-dropped-by-kernel !=3D 0.=
=20
And the rest of drop packages

Is possible to get info why the packages are dropped?

What is the relation between ethtool rx-dropped-by-kernel and ifconfig=20
drop package ?

The output from ifconfig eth0 and ethtool -S eth0 executed one after ot=
her:


# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:1D:11:91:00:00
           inet addr:172.18.208.187  Bcast:0.0.0.0  Mask:255.255.252.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:967819 errors:0 dropped:54676 overruns:0 frame:0
           TX packets:467 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:110916831 (105.7 MiB)  TX bytes:45317 (44.2 KiB)
           Base address:0x8000

ethtool -S eth0
NIC statistics:
      rx-dropped-by-kernel: 628278
      rx-large-frame-errors: 0
      rx-short-frame-errors: 0
      rx-non-octet-errors: 0
      rx-crc-errors: 0
      rx-overrun-errors: 0
      rx-busy-errors: 0
      rx-babbling-errors: 0
      rx-truncated-frames: 0
      ethernet-bus-error: 0
      tx-babbling-errors: 0
      tx-underrun-errors: 0
      rx-skb-missing-errors: 0
      tx-timeout-errors: 0
      tx-rx-64-frames: 227705
      tx-rx-65-127-frames: 743446
      tx-rx-128-255-frames: 117818
      tx-rx-256-511-frames: 43480
      tx-rx-512-1023-frames: 21406
      tx-rx-1024-1518-frames: 81741
      tx-rx-1519-1522-good-vlan: 0
      rx-bytes: 239178758
      rx-packets: 1235130
      rx-fcs-errors: 2
      receive-multicast-packet: 293898
      receive-broadcast-packet: 936991
      rx-control-frame-packets: 0
      rx-pause-frame-packets: 0
      rx-unknown-op-code: 0
      rx-alignment-error: 0
      rx-frame-length-error: 0
      rx-code-error: 0
      rx-carrier-sense-error: 1
      rx-undersize-packets: 0
      rx-oversize-packets: 0
      rx-fragmented-frames: 0
      rx-jabber-frames: 1
      rx-dropped-frames: 0
      tx-byte-counter: 51355
      tx-packets: 467
      tx-multicast-packets: 0
      tx-broadcast-packets: 132
      tx-pause-control-frames: 0
      tx-deferral-packets: 0
      tx-excessive-deferral-packets: 0
      tx-single-collision-packets: 0
      tx-multiple-collision-packets: 0
      tx-late-collision-packets: 0
      tx-excessive-collision-packets: 0
      tx-total-collision: 0
      reserved: 0
      tx-dropped-frames: 0
      tx-jabber-frames: 0
      tx-fcs-errors: 0
      tx-control-frames: 0
      tx-oversize-frames: 0
      tx-undersize-frames: 0
      tx-fragmented-frames: 0

[1] - http://www.novell.com/support/kb/doc.php?id=3D7007165

Thanks.

Regards,
An=EDbal
