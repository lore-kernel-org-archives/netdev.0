From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 14 Apr 2011 18:45:24 +0200
Message-ID: <1302799524.3248.37.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
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
	 <D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA723F1.7000901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Gu <wei.gu@ericsson.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65044 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253Ab1DNQp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 12:45:29 -0400
Received: by wya21 with SMTP id 21so1568881wya.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 09:45:27 -0700 (PDT)
In-Reply-To: <4DA723F1.7000901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 avril 2011 =C3=A0 09:42 -0700, Alexander Duyck a =C3=A9crit=
 :

> The only issue I have found so far with the ixgbe driver is the fact=20
> that apparently rx_no_buffer_count is apparently always going to be 0=
 on=20
> 82599, and that isn't so much a driver problem as a hardware limitati=
on=20
> as the HW counter was removed in 82599.  However since the hardware w=
as=20
> capable of going faster on the other kernels what this likely means i=
s=20
> that the rx_missed_errors are due to the driver not providing Rx buff=
ers=20
> fast enough.
>=20
> I'm doing some more digging into this now.  One thought that occurred=
 to=20
> me is that if the patch you mention is having some sort of effect thi=
s=20
> could be a sign of perhaps a kernel timer or scheduling problem.

We could try to instrument the delay betwen hardware IRQ and napi
handler called.



