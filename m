From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] Use IRQF_SHARED instead of SA_SHIRQ
Date: Sun, 6 Aug 2006 10:57:10 -0700
Message-ID: <200608061057.19894.flamingice@sourmilk.net>
References: <200608050057.09787.flamingice@sourmilk.net> <200608051237.36995.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1974367.0ROs07fV4j";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:6623 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751654AbWHFR53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 13:57:29 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608051237.36995.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1974367.0ROs07fV4j
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Saturday 05 August 2006 03:37, Michael Buesch wrote:
> On Saturday 05 August 2006 09:57, Michael Wu wrote:
> > Use IRQF_SHARED instead of SA_SHIRQ
> >
> > This patch switches all instances of SA_SHIRQ to IRQF_SHARED for drivers
> > in the drivers/net/wireless/d80211 directory. According to
> > feature-removal-schedule.txt, the interrupt related SA_* flags are
> > obsolete and should be replaced by the appropriate IRQF_* version before
> > January 2007.
> >
> > Signed-off-by: Michael Wu <flamingice@sourmilk.net>
>
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
>
> Are you also planning to do such a patch against softmac-bcm43xx?
> (Mainline)
>
Nope.

http://kernel.org/git/?p=linux/kernel/git/linville/wireless-2.6.git;a=commit;h=1fb9df5d3069064c037c81c0ab8bf783ffa5e373

-Michael Wu

--nextPart1974367.0ROs07fV4j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE1i1/T3Oqt9AH4aERAv3vAJ9Jb7jxYQOpIN5JrpaI8Ga1PKa0WwCfe+NC
+MRMf+toUxhISQhrbYL/uls=
=lGwV
-----END PGP SIGNATURE-----

--nextPart1974367.0ROs07fV4j--
