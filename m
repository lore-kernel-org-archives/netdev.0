From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: bind and O_NONBLOCK
Date: Sat, 22 Sep 2007 09:21:06 -0700
Message-ID: <46F540F2.1090109@redhat.com>
References: <46F35DD9.4000909@redhat.com> <20070922161414.GA29637@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Alan Cox <alan@redhat.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbXIVQVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 12:21:23 -0400
In-Reply-To: <20070922161414.GA29637@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Evgeniy Polyakov wrote:
> So, did I understand you correctly, that you want to introduce networ=
k
> AIO here? (for example on behalf of work queue or something else?)

See Alan's mail.  All this was his proposal, I just got it accepted
upstream.

The problem to solve is if you have a distributed network port set.
Apparently NetBIOS has it but I could also imagine this to be useful in
cluster implementations which have to appear as one machine.  In this
case, before binding to a given port, you have to make sure no other
machine already handles this port.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG9UDy2ijCOnn/RHQRAvntAKC6F6Pz6zHd/iZLFECOZ0MxlhdPBQCgjrLC
V9cazPF5jjf2eUSr7ZKDSas=3D
=3D0v1W
-----END PGP SIGNATURE-----
