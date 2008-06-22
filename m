From: Andrew Savchenko <Bircoph@list.ru>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Sun, 22 Jun 2008 17:07:14 +0400
Message-ID: <200806221707.22348.Bircoph@list.ru>
References: <200806201037.46687.Bircoph@list.ru> <20080620084131.3313abe8@speedy> <Pine.LNX.4.64.0806221220540.27261@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2568399.13LfdU9z0l";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	linux-kernel@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	shemminger@vyatta.com, Jeff Garzik <jeff@garzik.org>,
	sorbica@icplus.com.tw, Jesse Huang <jesse@icplus.com.tw>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1-2.mail.ru ([194.67.23.121]:26102 "EHLO mx1.mail.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751516AbYFVNHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2008 09:07:31 -0400
In-Reply-To: <Pine.LNX.4.64.0806221220540.27261@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2568399.13LfdU9z0l
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

On Sunday 22 June 2008 13:23, Pekka J Enberg wrote:
> On Fri, 20 Jun 2008, Stephen Hemminger wrote:
> > The code should enable/disable anything it needs based on the
> > MTU size in the change_mtu call. If the driver needs to
> > reallocate buffers, change receiver settings, make sacrifices
> > to deities, or phone home that is the place to do it. In other
> > words no compile or config option fro MTU settings please.
>
> Right, so how about something like this instead? Andrew, can you
> test the following patch? You need all the other patches from
> the previous series modulo the last patch. Thanks!

Ok, I replaced old ipg-make-jumbo-frame-support-configurable with=20
newer version. It works fine, I tuned MTU in the range from 68 to=20
10240 bytes )).

Thanks for the patch, awaiting for it in the main kernel tree.

Sincerely yours,
Andrew

--nextPart2568399.13LfdU9z0l
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBIXk6CAvwbVeyQBdURArAmAKCRcgxVAJn+wEGFOOH8FuNmTdulawCdHlmn
zR/5FbhIghjw+WMnQGVLtUQ=
=DacC
-----END PGP SIGNATURE-----

--nextPart2568399.13LfdU9z0l--
