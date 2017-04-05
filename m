From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH] batman-adv: Use net_device_stats from
	struct net_device
Date: Wed, 05 Apr 2017 16:09:05 +0200
Message-ID: <2848897.eWlOuJHVo0@bentobox>
References: <1491392791-30041-1-git-send-email-tklauser@distanz.ch>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart16955875.CyQnhcT5fl";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>,
 Antonio Quartulli <a@unstable.cc>, Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1491392791-30041-1-git-send-email-tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
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

--nextPart16955875.CyQnhcT5fl
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Mittwoch, 5. April 2017 13:46:31 CEST Tobias Klauser wrote:
> Instead of using a private copy of struct net_device_stats in struct
> batadv_priv, use stats from struct net_device.
> 
> Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
> ---
>  net/batman-adv/distributed-arp-table.c | 9 +++++----
>  net/batman-adv/soft-interface.c        | 2 +-
>  net/batman-adv/types.h                 | 2 --
>  3 files changed, 6 insertions(+), 7 deletions(-)

Nice find. I had to look up when the code was introduced and when the
common netdev stats member was added. Interestingly, both were from
2007 :)

Applied in ab044f8e3eaf84c4cc95d7606fadfdfa006dc8ec [1]

Thanks,
	Sven

[1] https://git.open-mesh.org/linux-merge.git/commit/ab044f8e3eaf84c4cc95d7606fadfdfa006dc8ec
--nextPart16955875.CyQnhcT5fl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljk+oEACgkQXYcKB8Em
e0aRJhAAlhOX+KTNyH12m2d0ZKtokik4wGN8eQI8mWTcpS9AdVauKjqrW36p9JuY
mnJ0ySSHnXriEfoleE/PTe/cn+TGqMs9k6PNGVUfsr+AqiBBYx1DL8WcjWi7ch9V
wPfpBDDrglKn6D4hwkP65ooJdscT4cdtxwhThxtJv2aqt+N5fK6roDhwi1VrCVwy
iBnuvgmrj8C4OrkzkfQ/GsruBTSoLHIm2eGYVJbHaNwNZASvsaTrm1pNYTR+Ysru
ryX1PRLEx4QtlhTUqkQrSANfEUobnquNXEVHqvUmsMHglhh1sZBiW00OeJsdyWe1
EWtZxvG6g96p1LGe9Hl9uOclRIYze4Plmhc0Bo7av+Ws75nMvMcrrl2O2Vz8n5e3
3xP2aNM4EX4l85qfZshze+Y6cSe14WAI7Dk9dyzLko75SWMMj3iwNSeJXu7ZShig
NfQoWREyToIVrG8Gx6Ah0PakSWl2NwEPvIoy7Ic98PXMUq/xdUybSc2WuQwDZZW3
rhDe56YWycg4hPqwhr1SeH6caYNO/4EUm3EwQge16mVN7010WjO1m4L3VLrmp+5k
DVQ4S64v0/FHCKKfOh0Fr6cARmCWa+Sqp1uuFnyxNdjEF7qXmVz/R1Ai/MnY70b2
muWw9vZVFhc81Wl92/clcY+WQBgWzX3i/Vs7jYLbSUsxXMeTuwg=
=Xawn
-----END PGP SIGNATURE-----

--nextPart16955875.CyQnhcT5fl--
