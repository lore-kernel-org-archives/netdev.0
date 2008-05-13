From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 02/18] flag parameters: paccept
Date: Mon, 12 May 2008 21:42:31 -0700
Message-ID: <48291C37.2030403@redhat.com>
References: <200805062118.m46LI7SS004041@devserv.devel.redhat.com> <20080512211056.16e07167.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org, Roland McGrath <roland@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbYEMEnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 00:43:14 -0400
In-Reply-To: <20080512211056.16e07167.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> because afacit arm doesn't implement set_restore_sigmask() and nor do=
es
> it need to, because it doesn't set HAVE_SET_RESTORE_SIGMASK.

pselect isn't define if HAVE_SET_RESTORE_SIGMASK isn't defined.  That's
fine since pselect offers nothing over select except the signal
handling.  For paccept we'll have to be a bit more sophisticated, I'm
afraid.  Patch in a few minutes.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKRw32ijCOnn/RHQRArz0AJ9RXoICEi/1Wmc2g/Xg7QMpaRfMjACggwhC
ON/2WP6i03QBerzu6qe/iPs=3D
=3DS2H+
-----END PGP SIGNATURE-----
