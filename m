From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] lne390 and Jensen Alphas
Date: Sat, 29 Mar 2008 19:32:28 +0100
Message-ID: <200803291932.30204.florian.fainelli@telecomint.eu>
References: <209D18A1-2B61-47F8-B1DC-067C1E676B9D@ccac.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Carsten Jacobi <carsten@ccac.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:38121 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbYC2S1Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 14:27:16 -0400
In-Reply-To: <209D18A1-2B61-47F8-B1DC-067C1E676B9D@ccac.rwth-aachen.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Carsten,

Le samedi 29 mars 2008, Carsten Jacobi a =E9crit=A0:
> Now, since I posted the patch twice to the linux-kernel mailing list
> without having any snippet of the code getting into the official
> kernel source I try it with this mailing list for a change.
> The code itself is supposed for the kernel 2.4.x series but should
> apply to 2.6.x as well. Is there something that speaks against
> pushing it up to the git repository?

=46irst of all, network drivers maintainers only accept inline patches =
that can=20
be reviewed in the mail, such that they do not have to extract the patc=
h and=20
read it, but can comment directly in the body of the email. See=20
http://lxr.linux.no/linux/Documentation/SubmittingPatches (also in the =
linux=20
tarball)

Second, your patch does not apply to the the 2.6.25-rc7 tree which is a=
 major=20
stopper for its merge into the netdev repository :

patching file drivers/net/lne390.c
Hunk #1 succeeded at 95 (offset 1 line).
Hunk #2 succeeded at 243 (offset 21 lines).
Hunk #3 FAILED at 272.
Hunk #4 FAILED at 379.
Hunk #5 FAILED at 421.
Hunk #6 FAILED at 445.

Should be easy to fix.

=46inally, your patch looks good, I have noticed that :

1) There are quite some lines which are more than 80 columns long, fix =
this=20
and use the checkpatch.pl script to make sure there are not any

2) Why add an "activate" module parameter if this case is only for the =
Jensen=20
Alphas series ? Would not it be easier to do this inside an ifdef such =
that=20
this does not confuse people who do not have a Jensen Alpha ?

3) Cannot this activation code be done in the Alpha Jensen architecture=
 code ?=20
(Just an idea)

You are very close to getting this merged !
--=20
Cordialement, Florian Fainelli
------------------------------
