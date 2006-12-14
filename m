From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 1/6] d80211: add IEEE802.11e/WMM MLMEs, Status Code and Reason Code
Date: Wed, 13 Dec 2006 23:38:19 -0500
Message-ID: <200612132338.24077.flamingice@sourmilk.net>
References: <20061214040204.GA10643@mail.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart26506670.LL4jfXOneH";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:38952 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751313AbWLNEip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 23:38:45 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040204.GA10643@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart26506670.LL4jfXOneH
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 13 December 2006 23:02, Zhu Yi wrote:
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
>
You should probably have more in the description..

> ---
>
>  include/net/d80211_mgmt.h |  148
> +++++++++++++++++++++++++++++++++++++++++++++ 1 files changed, 148
> insertions(+), 0 deletions(-)
>
d80211_mgmt.h was recently merged into include/linux/ieee80211.h.

> d83f6236e756f5f0bb1484d991884444f06704de
> diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
> index 87141d4..450c0a2 100644
> --- a/include/net/d80211_mgmt.h
> +++ b/include/net/d80211_mgmt.h
> @@ -14,6 +14,39 @@
>
>  #include <linux/types.h>
>
> +struct ieee802_11_ts_info {
> +	__le16 traffic_type:1;
> +	__le16 tsid:4;
> +	__le16 direction:2;
> +	__le16 access_policy:2;
> +	__le16 aggregation:1;
> +	__le16 apsd:1;
> +	__le16 up:3;
> +	__le16 ack_policy:2;
> +	u8 schedule:1;
> +	u8 reserved:7;
> +} __attribute__ ((packed));
> +
Mind eliminating the bitfields?

-Michael Wu

--nextPart26506670.LL4jfXOneH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFgNVAT3Oqt9AH4aERAjqiAJ44Mb68K7gmYTSUq8ASrQFI+8YErwCfUFhk
bFLpLDv55ow++P+FACyEOpo=
=Pjm8
-----END PGP SIGNATURE-----

--nextPart26506670.LL4jfXOneH--
