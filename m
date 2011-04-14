From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 14 Apr 2011 14:58:38 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
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
	 <D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>
	 <1302761251.3549.198.camel@edumazet-laptop>
 <1302762810.3549.233.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:61256 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757134Ab1DNG6y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 02:58:54 -0400
In-Reply-To: <1302762810.3549.233.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did the single flow test, it shows no rx error with 300kpps. While I =
was start multiple flow with same 300Kpps traffic, then it looks really=
 bad with high rx_missing_error.

Multiple Flow:
SUM: 191925 ETH8: 0  ETH10: 191925 ETH6: 0 ETH4: 0
SUM: 214634 ETH8: 0  ETH10: 214634 ETH6: 0 ETH4: 0
SUM: 237600 ETH8: 0  ETH10: 237600 ETH6: 0 ETH4: 0
SUM: 198925 ETH8: 0  ETH10: 198925 ETH6: 0 ETH4: 0
SUM: 249290 ETH8: 0  ETH10: 249290 ETH6: 0 ETH4: 0

Single Flow:
SUM: 302018 ETH8: 0  ETH10: 302018 ETH6: 0 ETH4: 0
SUM: 301849 ETH8: 0  ETH10: 301849 ETH6: 0 ETH4: 0
SUM: 302163 ETH8: 0  ETH10: 302163 ETH6: 0 ETH4: 0

Thanks
WeiGu
-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Thursday, April 14, 2011 2:34 PM
To: Wei Gu
Cc: Alexander Duyck; Peter Zijlstra; netdev; Kirsher, Jeffrey T
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le jeudi 14 avril 2011 =E0 08:07 +0200, Eric Dumazet a =E9crit :
> Le jeudi 14 avril 2011 =E0 13:42 +0800, Wei Gu a =E9crit :
> > Hi guys,
> > Do you think it was a bug in the kernel from 2.6.35.2 with Intel 10=
GE ixgbe driver?
> > If so shall I issue a Bug on the bugzilla, and which category? Caus=
e I'm not sure it was driver problem Or sched problem.
>
> This makes no sense to me.
>
> What is the maximum throughput you can get in pps before having packe=
t
> drops ?
>
> Please try with a single flow (to hit one queue, one cpu)
>
> Thanks
>

Also, please try to check if using smaller or bigger packets makes any =
change in this max throughput


