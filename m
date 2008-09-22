From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: routing =?UTF-8?Q?PF=5FPACKET=20sockets?=
Date: Mon, 22 Sep 2008 12:54:31 +0200
Message-ID: <5c4c427193d751928b131d43ab66879f@chewa.net>
References: <3f847c820809211610n731b0090wb6a9f94a3514f455@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Ra=C3=BAl_Hern=C3=A1ndez?= <rauhersu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:44266 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753406AbYIVKyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 06:54:33 -0400
In-Reply-To: <3f847c820809211610n731b0090wb6a9f94a3514f455@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 22 Sep 2008 01:10:54 +0200, "Ra=C3=BAl Hern=C3=A1ndez" <rauhers=
u@gmail.com>=0D
wrote:=0D
> I am trying to understand the possible options on dealing with=0D
> PF_PACKET and routing schemas: does the packet bypass the linux=0D
> routing table (as it is opened directly over a 'dev').=0D
=0D
Yes, by design.=0D
=0D
> Might this behaviour be configurable ?=0D
=0D
No. Use raw sockets from the adequate protocol family, if you want to=0D
inject packets into the network layer.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

