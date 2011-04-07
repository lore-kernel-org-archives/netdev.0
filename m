From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 07 Apr 2011 11:06:08 +0200
Message-ID: <1302167168.3357.12.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34268 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab1DGJGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 05:06:13 -0400
Received: by wya21 with SMTP id 21so2021536wya.19
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2011 02:06:11 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 16:39 +0800, Wei Gu a =C3=A9crit :
> I'm only insert a prerouting hook to make a copy of the incomming
> packet and swap the L2/L3 header, send it back on the same interface.
>=20

Small packets or big ones ?

You dont need to copy the packet, its expensive.


> BTW, some times I notices that the perf tool was not mapping the
> symbol correclly, I don't why?
>=20

You might try to put ixgbe in static kernel, not in a module.

> I will try a fresh install of kernel 2.6.30 and do the test with the
> shipped ixgbe driver again.
>=20

OK thanks.





