From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next] net: More vlan tests before registering
 netdevice
Date: Sun, 4 Jan 2015 06:32:45 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63BB25FA@avmb3.qlogic.org>
References: <1420007736-30822-1-git-send-email-Yuval.Mintz@qlogic.com>
	<20150102.155621.2190810414905057279.davem@davemloft.net>
 <20150102.155743.1836127158044264148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:13966 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750790AbbADGcs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jan 2015 01:32:48 -0500
In-Reply-To: <20150102.155743.1836127158044264148.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I guess this is fine as a defensive test, so I'll apply this.
> > But do you actually know of any devices which have violated this ru=
le either=20
> > now or in the past?
> > I quickly tried to audit the entire tree for this right now and fou=
nd no problems.
>=20
> Actually, reverted.
>=20
> Nothing makes me more angry than a patch that wasn't even build teste=
d:
>=20
> net/core/dev.c: In function =A1register_netdevice=A2:
> net/core/dev.c:6285:57: error: expected =A1)=A2 before =A1{=A2 token
> net/core/dev.c:6378:1: error: expected expression before =A1}=A2 toke=
n
> net/core/dev.c:6277:4: error: label =A1out=A2 used but not defined
> net/core/dev.c:6378:1: warning: control reaches end of non-void funct=
ion [-
> Wreturn-type]

Sorry about that.
Don't know how that happened, but obviously I can't make any excuses.

Regarding your previous question - I hit it while implementing vlan fil=
tering
offload on a new [yet-to-be-published] qlogic driver; Don't know if any=
one
actually had that issue in-tree.
