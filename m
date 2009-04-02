From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 07:06:07 -0400
Message-ID: <49D49C1F.6030306@novell.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <20090402091639.GA30126@gondor.apana.org.au> <49D484F5.2000400@redhat.com> <20090402092936.GA30333@gondor.apana.org.au> <49D487A6.407@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9803AE3409749F9CCEB49D91"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:42872 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbZDBLD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 07:03:58 -0400
In-Reply-To: <49D487A6.407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9803AE3409749F9CCEB49D91
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Herbert Xu wrote:
>> On Thu, Apr 02, 2009 at 12:27:17PM +0300, Avi Kivity wrote:
>> =20
>>> If tap told us when the packets were actually transmitted, life
>>> would be  wonderful:
>>>    =20
>>
>> And why do we need this? Because we are in user space!
>>
>>  =20
>
> Why does a kernel solution not need to know when a packet is transmitte=
d?
>

You do not need to know when the packet is copied (which I currently
do).  You only need it for zero-copy (of which I would like to support,
but as I understand it there are problems with the reliability of proper
callback (i.e. skb->destructor).

Its "fire and forget" :)

-Greg


--------------enig9803AE3409749F9CCEB49D91
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUnB8ACgkQlOSOBdgZUxmsGwCfT3fimLl0+bnt3+Sma8FpZ92+
GEwAnim4V3RObdYhVUCcYWJlm8SG6dFQ
=iwKi
-----END PGP SIGNATURE-----

--------------enig9803AE3409749F9CCEB49D91--
