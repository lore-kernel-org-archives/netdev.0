From: Soren Hansen <soren@ubuntu.com>
Subject: Re: r8169 patches
Date: Fri, 29 Jun 2007 01:50:47 +0200
Message-ID: <20070628235047.GM4838@atlas.linux2go.dk>
References: <20070628090054.GH4838@atlas.linux2go.dk> <20070628211036.GA4233@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GU3/x65mZ6MFE8p3"
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlas.linux2go.dk ([88.198.22.52]:41322 "EHLO atlas.linux2go.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762270AbXF2ASu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 20:18:50 -0400
Content-Disposition: inline
In-Reply-To: <20070628211036.GA4233@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--GU3/x65mZ6MFE8p3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 28, 2007 at 11:10:37PM +0200, Francois Romieu wrote:
> > I have an Asrock ConRoe945G-DVI motherboard with a RTL8111/8168B in
> > it.  The stock r8159 driver locks up from time to time. I've
> > described it here: https://launchpad.net/bugs/121815 . The patchset
> > at http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc3/ seems to
> > fix it.  Can you explain why the patchset is not in the mainline
> > kernel?
> 1. thanks for the report

Thanks for providing the patch!

> 2. increase net.core.wmem_max, ping -f -q -l xx -s yy with xx and yy
>    big enough and the driver will _still_ stop receiving/transmitting :o(

Oh, dear.

> 3. if I take the time to write a nice message to tell you why, it will
>    delay me:
>    - publishing an updated patchset against -rc6 that can handle davem's
>      git-net with minor pain for akpm
>    - preparing a serie for Jeff
>    - answering the rot^Wpending r8169 reports

Thanks for taking time to responding anyway!

The reason I asked was that I was hoping the response would be that the
patchset had no know regressions, but still lacked testing. In that
case, I would have discussed its inclusion in our (Ubuntu's) alpha
releases with our kernel team, but if you feel you're on track already,
I'll stop annoying you. :)

Thanks for your time.

--GU3/x65mZ6MFE8p3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFGhElXonjfXui9pOMRAhb5AJ91DeZ3SrJ3tg491aEFJfea515ypACgjHHW
u9NzZtqFRrusDm0cGJ56fvY=
=q051
-----END PGP SIGNATURE-----

--GU3/x65mZ6MFE8p3--
