From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] bna: fix error handling of
 bnad_get_flash_partition_by_offset()
Date: Fri, 10 Feb 2012 10:15:34 +0300
Message-ID: <20120210071534.GE4204@mwanda>
References: <20120209104934.GC5540@elgon.mountain>
 <E5313AF6F2BFD14293E5FD0F94750F86B1FB8B0A20@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TD8GDToEDw0WLGOL"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:31365 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab2BJHN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:13:58 -0500
Content-Disposition: inline
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86B1FB8B0A20@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TD8GDToEDw0WLGOL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 09, 2012 at 05:53:20PM -0800, Rasesh Mody wrote:
> >From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> >Sent: Thursday, February 09, 2012 2:50 AM
> >
> >The current error handling doesn't work because we flash_part is a u32
> >so the checks for negative error codes don't work.  I considered making
> >things signed but I don't know the hardware enough to say if that's a
> >problem.  Really, we don't use the error codes so just returning zero
> >for all problems is fine.
>=20
> Hi Dan,
>=20
> We can't return 0 from the bnad_get_flash_partition_by_offset() on
> error as the flash partition 0 is a optrom partition. Also we got
> comments to return proper Linux error codes as ethtool application
> expects so.

It's already treated as an error.  A return value of zero means the
user gets a return value of -EFAULT.  I'm slightly confused by your
email.

My patch was already merged into git.  Can you just send a patch
which does what you want?  I don't know the subsystem well enough to
say how you want zero returns to be handled if the original code was
not correct.

regards,
dan carpenter


--TD8GDToEDw0WLGOL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPNMQWAAoJEOnZkXI/YHqRtksP/Rr9NiqIF5VJ8uilVIcX9Slf
vPx/ELH24OSDhOnUtZO/51P/LXwQlwlKEFt/5lEvigI2WCVfFDgyucSB8x9/W2uL
t6/hG9yKra/cYbZb/462nawsOLNzTMTAl1MWa0oznyt/V9h2x51ommqQ59ZEfuMa
DjwIssLgumLKEwqNy4JajuTo+FyxIAEc/QVzC0360E4ZroTCjKK3ZjOuPIp2l//6
54ZTz7ADr/49/lOWLEsDu345aefVC9FZwqGdz/FZvly5p21WNzEKO0wlav9fKSKC
36qPu1n9RkbuE8sX8f5b7udEe5cefhQf1nfF1LfU6JIaw3mxT9odJ4A7KY2+iHNH
ieKvYZSmHlZOShnYm9diiCyMgf+fEHQT21kt9Gqrc4WfAQNT/E+3CuOreERPYj/O
MZK4hV/IPFzcLpC46Og4xKvsnZH38+fsuOxG90ip8ouNbBTeFVzIJ52WiK381WE0
tNhapzG5ajvZTBRPjieHVYixzAS+j8BHjerSC4xl6nP23VzDKpK9ksE/adF96+t6
AYrX4b+PDHj6bXqpQ+U75Vkh1uKZKJnMDtQZ+jQm/YyX9+L6emUydljHhbQCNe4h
/ioeAkmpvsQzUjvzwxseKZzt8NAZqZjrspOZuVakQZ2bDp2FHeuLS7H42+CBjitp
7WxmptDr8O4f+Q+WSKfz
=XiXT
-----END PGP SIGNATURE-----

--TD8GDToEDw0WLGOL--
