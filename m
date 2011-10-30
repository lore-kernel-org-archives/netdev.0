From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-10-29
Date: Sun, 30 Oct 2011 10:05:04 +0100
Message-ID: <1676645.jsUbFMd6Ud@sven-laptop.home.narfation.org>
References: <1319875606-7794-1-git-send-email-lindner_marek@yahoo.de>
	<20111030.030745.1245988853394270780.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4100833.btI8hd8mvK";
	micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lindner_marek-LWAfsSFWpa4@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20111030.030745.1245988853394270780.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--nextPart4100833.btI8hd8mvK
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Sunday 30 October 2011 03:07:45 David Miller wrote:
[...]
> Make a common header:
> 
> 	struct tt_entry_common {
> 		u8 addr[ETH_ALEN];
> 		struct hlist_node hash_entry;
> 	};
> 
> Then use that at the beginning of both structures:
> 
> 	struct tt_local_entry {
> 		struct tt_entry_common common;
> 		unsigned long last_seen;
> 		...
> 	};
> 
> 	struct tt_global_entry {
> 		struct tt_entry_comomn common;
> 		struct orig_node *orig_node;
> 		...
> 	};
> 
> And &p->common is what gets passed into tt_response_fill_table().

Thanks for the pull. This is exactly the long term solution we want to submit 
later to net-next. But we also wanted to keep the patch as small as possible 
for stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org

Thanks,
	Sven
--nextPart4100833.btI8hd8mvK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOrRNAAAoJEF2HCgfBJntGNFQQAKL6R4xgPlPztx0oTBsNpgjk
vXR5hSG38MBeR5M410vwAG3xvswsORbzEPyojCfesM8eKWDhgqycROR6GRC3g1yd
GQkMN7rwQ6kcKXIjpZdM9a3G1UfDmaCm/VWojs0IzOShCXVgibp0tVtTepjtp58o
9HPtqhLFeOlErIbp5bakLBDScnU0HeAS8XzxlaiMrHfX5z239sQO799ZgPVQgU+f
Ahm7VPA3RpQJSeNEr6bdFJQPbU/yD3NplvDyvpNshEbKW/xvdWxIFjFpZHyIe/hN
b8OKwAovZep3hXD8QWmV2bK+AztgZ47SJpDz4WZHjD/qqvDZzVBCXiuWbuZpTeQA
rIUdEi32VlBQxNxDacRWjo6HopS69sASqR/Kyf4b5ZayHGoAUqr/kn+NlzETdmCY
RuDDeCaMNjsf+wddG4PFTAv+m5s1hj8F+tjO7bYV5LxUGqq5/rNcs+SEjEFg2yUn
xW/hguYVNIAt6K/00tVuzlmg58I/ZHudGqakNWYr2NbU4ddiyfUvekhPoYwWd1Ip
YvvKNSjzoS2j6ft/nxEj0FVOGjBPsAEdZ7XaQbRAIStc7EclsQ9gaxf0n7oJ6o6v
7xPtj5OVrL9apkSR7Ixinh7axh0dvStk4cXejt6hSzCTfMom5RyvqD8jcvSzIJJ4
PNdIZWTSBxzfTkKdSD2P
=bF0P
-----END PGP SIGNATURE-----

--nextPart4100833.btI8hd8mvK--
