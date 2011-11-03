From: =?iso-8859-1?B?Q2FybG9zIFBl824gQ29zdGE=?= <carlospeon@hotmail.com>
Subject: RE: bnx2x kerneloops
Date: Thu, 3 Nov 2011 09:09:31 +0100
Message-ID: <SNT113-W52BD826F2982A79AD790DDDBD50@phx.gbl>
References: <SNT113-W64251CF45774789989C835DBD40@phx.gbl>,,,<1320234845.2688.3.camel@lb-tlvb-dmitry>,<SNT113-W38A7D5A673342F70A1F808DBD40@phx.gbl>,<1320257981.12759.2.camel@lb-tlvb-dmitry>,<SNT113-W9B428C68CF654B313283EDBD50@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt0-omc1-s14.snt0.hotmail.com ([65.55.90.25]:8054 "EHLO
	snt0-omc1-s14.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755067Ab1KCIJc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Nov 2011 04:09:32 -0400
In-Reply-To: <SNT113-W9B428C68CF654B313283EDBD50@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Yes of course.
I attach the /var/log/messages file, before the Watchdog I only can see=
:=A0
Oct 31 10:40:10 apache1-pro kernel: do_IRQ: 4.227 No irq handler for ve=
ctor (irq -1)

The scenario: web server with ~ 15.000 tcp connections (established + t=
ime wait + close wait) and two Broadcom NICs in active/passive bonding.=
 The web server is behind a load balancer.

Thanks.

> Subject: RE: bnx2x kerneloops
> From: dmitry@broadcom.com
> To: carlospeon@hotmail.com
> CC: netdev@vger.kernel.org
> Date: Wed, 2 Nov 2011 20:19:41 +0200
>=20
> It looks like problem happened before the WATCHDOG, FW has asserted f=
or
> some reason.
> Can you provide /var/log/messages and describe in details the scenari=
o?
> Thanks
>=20

 		 	   		   		 	   		  