From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH 1/8] Phonet: fix NULL-deref in a8059512b120362b15424f152b2548fe8b11bd0c
Date: Tue, 8 Mar 2011 22:59:41 +0200
Message-ID: <201103082259.41844.remi@remlab.net>
References: <201103081556.18877.remi.denis-courmont@nokia.com> <1299592626-18510-1-git-send-email-remi.denis-courmont@nokia.com> <20110308.112923.39177383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:35918 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976Ab1CHU7s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 15:59:48 -0500
Received: from basile.remlab.net (cs27069010.pp.htv.fi [89.27.69.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: remi)
	by yop.chewa.net (Postfix) with ESMTPSA id 0C4A6FD9
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2011 21:59:45 +0100 (CET)
In-Reply-To: <20110308.112923.39177383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

On March 8th 2011 21:29:23 David Miller, you wrote :
> You don't even read what I tell you, which makes reviewing your work
> insanely frustrating.

=46air enough.

You were the one complaining about the Nokia mail server being insanely=
=20
broken (in private email by the way). So I have to read stuff at home, =
and=20
implement it the next day at work. Informations do get lost at night. I=
 don't=20
need to mention I don't like this is frustrating for us Nokians as well=
=2E

(...)
> It also irks me that you persisted to provide the most terse possible
> one-line commit message.  Have a conversation in your commit message,
> this isn't for you it's for other people trying to understand your
> work.

I'm trying to fix the terrible mess that ST-Ericsson left of the Phonet=
 stack=20
here. This wouldn't be an issue if the crap hadn't been merged, or if I=
 had=20
been given enough time to voice my concerns.

Just one WTF? out of many:

        static u8 data[4] =3D {
                0x03, 0x04,
        };
        data[2] =3D pn->tx_fc;
        data[3] =3D pn->rx_fc;

(Those coffee-deprivated, note the 'static' keyword.) I wonder if the g=
uy ever=20
wrote C (not C++) before he came to kernel.org and left as quickly.

I am totally fine with strictness on your part. I do genuinely believe =
it=20
improves code quality and such, and do try to apply similar patterns wh=
en I am=20
the reviewer. So I present my apologizes for my series  of unintended=20
violations of The Process.

I just wish you'd been as strict back then. Nobody would be having this=
=20
pointless non-technical discussion... Well... I'll fix it tomorrow beca=
use I=20
don't want that kind of crap in the Linux kernel anyway.

Thanks every one you for your cooperation.

--=20
R=E9mi
