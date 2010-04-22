From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: [PATCH] Socket filter ancilliary data access for skb->dev->type
Date: Thu, 22 Apr 2010 14:11:05 +0100
Message-ID: <20100422131105.GS19334@cel.leo>
References: <20100422121253.GR19334@cel.leo>
 <4BD040FE.3000809@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="phbq2bkSb+hZnunM"
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:60153 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754586Ab0DVNLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 09:11:09 -0400
Content-Disposition: inline
In-Reply-To: <4BD040FE.3000809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--phbq2bkSb+hZnunM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 22, 2010 at 02:28:46PM +0200, Patrick McHardy wrote:
> I think we should be adding a check whether skb->dev is non-NULL here
> since filters can also be attached to netlink sockets. The same applies
> to SKF_AD_IFINDEX.

What should the appropriate behaviour be here? Set A to some rogue value
- 0 or -1 seem appropriate? Or, abort the filter entirely (such as in
e.g. divide-by-zero, or invalid memory buffer access)?

Either way that sounds simple enough, I can hack that in and resubmit.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--phbq2bkSb+hZnunM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFL0ErpvLS2TC8cBo0RAsucAJ9Eia3u8d4C/q3F4lsbSVwF8NTGwQCgyiCI
W+oorlEpUfbXIK1zIFClaj8=
=smkN
-----END PGP SIGNATURE-----

--phbq2bkSb+hZnunM--
