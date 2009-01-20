From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB transfers
Date: Wed, 21 Jan 2009 00:28:38 +0100
Message-ID: <200901210028.41231.oliver@neukum.org>
References: <34115.192.168.0.40.1232483361.squirrel@server> <20090120.144719.120709836.davem@davemloft.net> <200901210017.19038.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ceggers@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:48008 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460AbZATX2J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 18:28:09 -0500
In-Reply-To: <200901210017.19038.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Wednesday 21 January 2009 00:17:18 schrieb Arnd Bergmann:
> > + =A0 =A0 =A0 buffer =3D kmalloc(size, GFP_NOIO);
>=20
> GFP_NOIO seems out of place in a network driver: there is nothing
> wrong with waiting for I/O here, so plain GFP_KERNEL should be fine.

What happens if you run nfs over that link?

	Regards
		Oliver

