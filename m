From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 14:55:50 -0600
Message-ID: <200501061455.53590.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501061335.55104.jeremy.guthrie@berbee.com> <16861.40858.80960.794144@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1938077.N2rRDRFtMu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16861.40858.80960.794144@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1938077.N2rRDRFtMu
Content-Type: multipart/mixed;
  boundary="Boundary-01=_XXa3BZ690xkxonk"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_XXa3BZ690xkxonk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46orgot the attachment. =20


On Thursday 06 January 2005 02:29 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  You only use CPU0 for packet processing. Also it seems you use  the
>  > > non-NAPI version of e1000.
>  >
>  > The E1000 driver is the stock driver in 2.4.28.
>
>  There is a kernel config option.  Use Rx Polling (NAPI)
>
>  > eth2 is TX only.  We don't receive anything on it.  This system should
>  > only ever RX on eth3 and TX on eth2 as part of its function.
>
>  Ok! So unidirectional traffic and CPU0 processes all skb's and passes th=
em
>  over to CPU1 which touches and frees them. You could try some other
>  affinity setting later on but there are so many options depending what
>  we want do. If we just want to compare 2.4/2.6 we can start out simple
>  with setting affinity so only one CPU. Which is almost what you got.
>  We reach all the complicated problems immediately... Now we pass skb's
>  between the CPU's which release cache bouncing and makes slab rebalance
> it's pools. So using just one CPU is probably better... If we had incoming
> pkts on eth2 eventually we could have had any use for CPU1.
>
>  Install NAPI-driver, set affinity so eth2/eth3 uses same CPU to start
> with.
>
>  The stats info you sent was almost impossible to read. See if you can get
>  only the rtstats.
>
>       --ro

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--Boundary-01=_XXa3BZ690xkxonk
Content-Type: text/plain;
  charset="iso-8859-1";
  name="results-2.4.28.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="results-2.4.28.txt"

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis|
        |     tot|      mc|     ute|        |  an_dst|  an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|
    9092|   21888|       0|       0|    1656|       0|       0|       9|      42|       0|    1836|    1833|       0|       0|  158622|     206|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       1|       1|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       1|       1|       0|       0|       9|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      14|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      14|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis|
        |     tot|      mc|     ute|        |  an_dst|  an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       9|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       1|       1|       0|       0|      14|       0|
       0|       2|       0|       0|       0|       0|       0|       0|       0|       0|       1|       1|       0|       0|      14|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       7|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       3|       0|
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis|
        |     tot|      mc|     ute|        |  an_dst|  an_src|        |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|
       1|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      16|       0|
       1|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      16|       0|
       1|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      16|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       8|       0|
       0|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       8|       0|
       2|       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|      16|       0|
       1|       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       8|       0|
       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       6|       0|
       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       6|       0|
       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       6|       0|
       2|       2|       0|       0|       1|       0|       0|       0|       0|       0|       1|       1|       0|       0|      24|       0|
       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       2|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       1|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       0|       2|       0|       0|       1|       0|       0|       0|       0|       0|       1|       1|       0|       0|      16|       0|
       0|       2|       0|       0|       1|       0|       0|       0|       0|       0|       1|       1|       0|       0|      16|       0|
       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       2|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       4|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|
       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|       0|

--Boundary-01=_XXa3BZ690xkxonk--

--nextPart1938077.N2rRDRFtMu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3aXZqtjaBHGZBeURAjLjAJkBi385GCSOhiNUVhsZwINncCXMKQCgkGNO
KF1TaJcccd9gfXJxV+yZeXs=
=A1iR
-----END PGP SIGNATURE-----

--nextPart1938077.N2rRDRFtMu--
