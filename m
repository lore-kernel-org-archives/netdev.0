From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Tue, 12 Apr 2011 09:22:59 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E49097D0@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <1302267400.4409.22.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	 <1302275223.4409.36.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
	 <1302330998.2656.113.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA3151B.4030507@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>
 <1302536577.4605.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:49737 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947Ab1DLBXm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 21:23:42 -0400
In-Reply-To: <1302536577.4605.1.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was not stress the NIC/CPU, since I only send 290Kpps 400byte packets=
 towards eth10. the CPU load almost 100%IDEL.

BTW, there are some problem with perf tool on 2.6.35.2, I will try to g=
et you the top offenders if possible.

Thanks
WeiGu

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Monday, April 11, 2011 11:43 PM
To: Wei Gu
Cc: Alexander Duyck; netdev; Kirsher, Jeffrey T
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le lundi 11 avril 2011 =E0 23:14 +0800, Wei Gu a =E9crit :
> I tried the ixgbe-3.3.8 (insmod ixgbe.ko RSS=3D8,8,8,8,8,8,8,8 FdirMo=
de=3D0,0,0,0,0,0,0,0 Node=3D0,0,1,1,2,2,3,3)  from e1000.sf.net both on=
 2.6.35.1 and 2.6.35.2, same observation as 3.2.10 ixgbe driver, On 2.6=
=2E35.2 it have high rx errors:
> Ethtool -S eth10 |grep error
>      rx_errors: 0
>      tx_errors: 0
>      rx_over_errors: 0
>      rx_crc_errors: 0
>      rx_frame_errors: 0
>      rx_fifo_errors: 0
>      rx_missed_errors: 2263088
>      tx_aborted_errors: 0
>      tx_carrier_errors: 0
>      tx_fifo_errors: 0
>      tx_heartbeat_errors: 0
>      rx_long_length_errors: 0
>      rx_short_length_errors: 0
>      rx_csum_offload_errors: 0
>      fcoe_last_errors: 0
>

It would be nice you post perf record / perf report results

During your stress , do

perf record -a -g sleep 10
perf report

And post "top offenders"

Thanks


