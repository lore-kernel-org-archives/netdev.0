From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 10:46:54 -0700
Message-ID: <46F1608E.7060908@redhat.com>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de> <46F15305.2030507@redhat.com> <20070919172653.GB18045@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbXISRrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 13:47:08 -0400
In-Reply-To: <20070919172653.GB18045@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andi Kleen wrote:
>> But the spec calls for a "null address" to be used and that's in my
>> understanding something different from using AF_UNSPEC.
>=20
> memset(&sockaddr, 0, sizeof(sockaddr)) should give you AF_UNSPEC

But the spec calls for <quote>null address for the protocol</quote>.

That means the family for the null address is the same as the family of
the socket.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8WCO2ijCOnn/RHQRAgtsAJ9qTFVj5QQbVG/hUflxo/6uPOfl4QCdHSX8
wi2GX7B0pht8VDaswYLqdpM=3D
=3DsMSg
-----END PGP SIGNATURE-----
