From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 10:04:39 -0700
Message-ID: <46F156A7.5000304@redhat.com>
References: <46F13E8B.4050309@redhat.com>	<p73sl5aveqh.fsf@bingen.suse.de>	<46F15305.2030507@redhat.com> <20070919.095251.45154496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33600 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbXISU0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 16:26:36 -0400
In-Reply-To: <20070919.095251.45154496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

David Miller wrote:
> It just occured to me that AF_UNSPEC might be used simply
> because "all zeros" might be a valid real bindable address
> for some address family.  And using AF_UNSPEC avoids that
> problem entirely.

Yes, but for IPv4/6 it's not an issue.  Some implementations might
handle all-zeros and the spec _currently_ calls for it.  In this case a=
n
alignment would be good.

I guess I'll just go ahead and file a problem report with the spec.
Maybe the Unix vendors will test their implementations in provide feedb=
ack.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8Vam2ijCOnn/RHQRAlw2AJwPCkD/GdX5YWCjsidhNXkGT71SiQCeLUDX
XimSWS2NMI9T8QxnnV3FDQ4=3D
=3D8XbG
-----END PGP SIGNATURE-----
