From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] net: batman-adv: Treat
	NET_XMIT_CN as transmit successfully
Date: Fri, 16 Dec 2016 10:19:20 +0100
Message-ID: <6927862.BQ2m90es0t@sven-edge>
References: <1479740432-3721-1-git-send-email-fgao@ikuai8.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1600043.WVOumjH58T";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, a@unstable.cc,
 fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org, gfree.wind-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1479740432-3721-1-git-send-email-fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart1600043.WVOumjH58T
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Montag, 21. November 2016 23:00:32 CET fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org wrote:
> From: Gao Feng <gfree.wind-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> The tc could return NET_XMIT_CN as one congestion notification, but
> it does not mean the packet is lost. Other modules like ipvlan,
> macvlan, and others treat NET_XMIT_CN as success too.
> 
> So batman-adv should add the NET_XMIT_CN check.
> 
> Signed-off-by: Gao Feng <gfree.wind-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/batman-adv/distributed-arp-table.c |  2 +-
>  net/batman-adv/fragmentation.c         |  2 +-
>  net/batman-adv/routing.c               | 10 +++++-----
>  net/batman-adv/soft-interface.c        |  2 +-
>  net/batman-adv/tp_meter.c              |  2 +-
>  5 files changed, 9 insertions(+), 9 deletions(-)

David marked your patches as "derefered" after "under review" and did not
apply them directly. Also Florian Westphal didn't continue the discussion
about the direction you should choose.

The patches were therefore queued up in the in batman-adv
671630d6aad0..eab7617142d2. They will be submitted later(tm) in a pull
request to David.

Thanks,
	Sven
--nextPart1600043.WVOumjH58T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAlhTsZgACgkQXYcKB8Em
e0brWRAA0EzqqBRRRyYw9PPLLVhqdpTfm9Gc6u5IGdd8o7wYnfULmHaaO8Buu7J/
3lFoX7hXWDtmYl7ysEm8+0AQVFgvsBbb+7/d9HGBng+AEtEjN9ToCcORP2+TDiRJ
a1tvfbtJgZnvl7T84AVqmfy3r6CYnxLIOA5v8XGvFHI+wHLZgGcLV4O0VhRx9k5/
OzKiOcLY8lhb8kRH6ds+fxUKxUvmj4EWAguwWkOzMS9Fz8d30CTI5RyvZXgzGwCo
gvAQAgRVhXlsdZUvCWm7KEjZOQ1Fg0gUfCPKEjhc1a8FV/tRONSLyyctOK88Jywf
S39rIoURIamQOhYT2IbAvsKY04u7OLJW7f64Ehr41CyJiWmBYfb7znK2i04C5oNK
SEnCo6GqDMkdcQ0krF0+Rf8xqzAWywuI9vRsXCXDpq82h/oGOJuEv9fUf6fe4v2m
1DBlMe+uuJrZh1wOBa+gwXM/OovVaegxIxiYOq/5LvQ7wez9kbD9Uh3e45xw/mCH
+Tt0dgAIMnZKqeNxt0/5d2qM4LHaIpdzQPEpSd7YC8YLv/Q81Z+clgBhWPKBDAX4
6XiKegAPzmgKgWoA8/omL06Yt50kOH06f4ePbgtJlVBKhnW6+TZylwPHVoT0+UZL
lBqpDtkXRRw+QRha+Zzf7iB2cjsca5pWFdgJgUsFBFAWgYPhkO0=
=OYZ0
-----END PGP SIGNATURE-----

--nextPart1600043.WVOumjH58T--
