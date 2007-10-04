From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted to managed
Date: Thu, 4 Oct 2007 10:34:43 -0400
Message-ID: <200710041034.48533.flamingice@sourmilk.net>
References: <20071004113343.552139D502B@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4274055.lTjFuKTD6v";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, johannes@sipsolutions.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:41456 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752018AbXJDOgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 10:36:42 -0400
In-Reply-To: <20071004113343.552139D502B@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4274055.lTjFuKTD6v
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 04 October 2007 07:33, Daniel Drake wrote:
> Fix this by unsetting the hard_start_xmit handler in ieee80211_if_reinit.
> It will then be reinitialised to the default (ieee80211_subif_start_xmit)
> in ieee80211_if_set_type.
>
Well.. this kinda sucks, but we can clean up the logic here later.

> +	BUG_ON(netif_running(dev));
This will never happen, so there's no point.

ACK with that bit removed.

Thanks,
-Michael Wu

--nextPart4274055.lTjFuKTD6v
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHBPoIT3Oqt9AH4aERAvyWAJ0Yk/x2lgZWeU/vfmXD2Q0+2pNt2ACgwcmf
G81XOr8CvwL+axSyABIVHY8=
=hnr9
-----END PGP SIGNATURE-----

--nextPart4274055.lTjFuKTD6v--
