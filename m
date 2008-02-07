From: Michael Monnerie <michael.monnerie@it-management.at>
Subject: Re: [Netatalk-admins] netatalk slow after system upgrade (possibly kernel problem?)
Date: Thu, 7 Feb 2008 01:49:44 +0100
Message-ID: <200802070149.45873@zmi.at>
References: <200801251255.48105@zmi.at> <200802051626.25030@zmi.at> <73F08C2B-C3F9-4846-962E-A3D2692804E0@supported.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart29334422.M4tpLIQOGx";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netatalk-admins@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Ralph =?iso-8859-15?q?B=F6hme?= <lists@supported.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsrv1.zmi.at ([212.69.162.198]:40101 "EHLO mailsrv1.zmi.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763919AbYBGAtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 19:49:51 -0500
In-Reply-To: <73F08C2B-C3F9-4846-962E-A3D2692804E0@supported.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart29334422.M4tpLIQOGx
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I received this e-mail, which could be the resolution to this problem. I=20
will test it with the customer tomorrow.

Is there a workaround possible from the Linux server, instead of=20
modifying all clients? As it runs with kernel 2.6.13, but not with=20
2.6.23, maybe some behaviour change via sysctl could help here.

On Mittwoch, 6. Februar 2008 Ralph B=F6hme wrote:
> Am 05.02.2008 um 16:26 schrieb Michael Monnerie:
> > Still, it runs quick within the VM
> > with kernel 2.6.13-15.15-smp from SUSE 10.0, but slow with more
> > recent kernels (I couldn't test every combination of course).
>
> Use the sniffer, Luke!
>
> If you find an ongoing sequence of ~5 packets sent by the server,
> ~200ms pause, client ACK, next turn, then you might me experiencing
> this:
>
> http://www.helios.de/support/ti.phtml?110
>
> Proposed solution:
> sysctl -w net.inet.tcp.delayed_ack=3D2 to be set on the client side.
> Note: the issue should be resolved with OS X 10.5.
>
> It seems as if /some/ server side TCP stacks don't like OS X 10.4
> delayed ACKs implementation.
>
> HTH,
> -Ralph



=2D-=20
// Michael Monnerie, Ing.BSc    -----      http://it-management.at
// Tel: 0676/846 914 666                      .network.your.ideas.
// PGP Key:         "curl -s http://zmi.at/zmi.asc | gpg --import"
// Fingerprint: AC19 F9D5 36ED CD8A EF38  500E CE14 91F7 1C12 09B4
// Keyserver: www.keyserver.net                   Key-ID: 1C1209B4

--nextPart29334422.M4tpLIQOGx
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQBHqlWpzhSR9xwSCbQRAs9iAKDeaNOGTOsyOM1G6jhJ3qEu65jIhwCdGMDK
lrxfkC7o/pz2FxqG6HFQfSU=
=sG9U
-----END PGP SIGNATURE-----

--nextPart29334422.M4tpLIQOGx--
