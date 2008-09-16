From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss: 4E1
Date: Wed, 17 Sep 2008 00:49:44 +0200
Message-ID: <m3tzcfvh87.fsf@maximus.localdomain>
References: <4f40a1df0809040045m6c5ff3d7s7d8ca2b624a0a8da@mail.gmail.com>
	<m3ljy1trr1.fsf@maximus.localdomain>
	<4f40a1df0809160845g55567209rb0ccc4cc041b0053@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?=
	<alvarezcabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:33993 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbYIPWtr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 18:49:47 -0400
In-Reply-To: <4f40a1df0809160845g55567209rb0ccc4cc041b0053@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Tue\, 16 Sep
 2008 17\:45\:21 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <alvarezcabanes@gmail.com> writes:

> Another question related with ixp4xx_hss... Why do you create network
> interfaces instead of character devices? Would it not be more general=
 to
> use these lasts (ppp over these could create the network interfaces)?

Well, I guess I just need network interfaces, not char devices.
PPP can of course create network interfaces, but it supports only PPP
protocol (and interface to generic PPP is in the works). Now the thing
supports Cisco HDLC, PPP, Frame-Relay, Ethernet-in-HDLC and X.25/LAPB.
--=20
Krzysztof Halasa
