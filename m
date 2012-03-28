From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCH v2] net/garp: avoid infinite loop if attribute already
 exists
Date: Wed, 28 Mar 2012 13:28:22 +0200
Message-ID: <4F72F5D6.5080903@dti2.net>
References: <4F70942B.5000102@ll.mit.edu> <1332874912-1979-1-git-send-email-david.ward@ll.mit.edu>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:63766 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285Ab2C1LfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 07:35:21 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.2)
	with ESMTP id md50021750458.msg
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 13:28:27 +0200
In-Reply-To: <1332874912-1979-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 27/03/2012 21:01, David Ward escribi=F3:
> An infinite loop occurred if garp_attr_create was called with the val=
ues
> of an existing attribute. This might happen if a previous leave reque=
st
> for the attribute has not yet been followed by a PDU transmission (or=
,
> if the application previously issued a join request for the attribute
> and is now issuing another one, without having issued a leave request=
).
>=20
> If garp_attr_create finds an existing attribute having the same value=
s,
> return the address to it. Its state will then get updated (i.e., if i=
t
> was in a leaving state, it will move into a non-leaving state and not
> get deleted during the next PDU transmission).
>=20
> To accomplish this fix, collapse garp_attr_insert into garp_attr_crea=
te
> (which is its only caller).
>=20

	I wouldn't mind if you credited me given that your patch now is based =
on my fix
and analysis. ;-)

Anyway...

Acked-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
