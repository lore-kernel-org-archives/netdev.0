From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 15/15] batman-adv: unbloat batadv_priv if
 debug is not enabled
Date: Tue, 15 Jan 2013 18:53:13 +1000
Message-ID: <20130115085313.GC30484@ritirata.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
 <1358120480-25960-16-git-send-email-ordex@autistici.org>
 <1358185000.19400.15.camel@joe-AO722>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="mojUlQ0s9EVzWg2t"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1358185000.19400.15.camel@joe-AO722>
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


--mojUlQ0s9EVzWg2t
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Joe,

On Mon, Jan 14, 2013 at 09:36:40 -0800, Joe Perches wrote:
> On Mon, 2013-01-14 at 09:41 +1000, Antonio Quartulli wrote:
> > diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
> []
> > @@ -284,12 +284,16 @@ struct batadv_priv {
> >  	atomic_t gw_bandwidth;		/* gw bandwidth */
> >  	atomic_t orig_interval;		/* uint */
> >  	atomic_t hop_penalty;		/* uint */
> > +#ifdef CONFIG_BATMAN_ADV_DEBUG
> >  	atomic_t log_level;		/* uint */
> > +#endif
> >  	atomic_t bcast_seqno;
> >  	atomic_t bcast_queue_left;
> >  	atomic_t batman_queue_left;
> >  	char num_ifaces;
> > +#ifdef CONFIG_BATMAN_ADV_DEBUG
> >  	struct batadv_debug_log *debug_log;
> > +#endif
> >  	struct kobject *mesh_obj;
> >  	struct dentry *debug_dir;
> >  	struct hlist_head forw_bat_list;
>=20
> How about moving one of these so
> there's only one #ifdef block.

Yeah. This is the main struct and actually it still needs some more houseke=
eping
(and some love).
It was initially sorted in another way, but as soon as we added new feature=
s it
lost its shape.

We will take care of that.

Thanks a lot!
Cheers,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--mojUlQ0s9EVzWg2t
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQ9Rj5AAoJEADl0hg6qKeO3tEQAJGG1jeEMiC2/ut0KK7JJPYw
JuO9RUMSs49e9TBwxRNq/N8r96Hf/qJKr5iyqI10JmyLq32oPXL1E6eWqSbpmGJ7
Zq+5gqO5UAy6hFjmGAvErYIHQV2Bc0Cmp3ZHkzvGE/XH88SGDVT7pPvvFf+f7mrQ
uK48Ivwdomq7R0q3AwsZX/i7YhlSz158Y8CeboRhwZRbajKVZgxmW/hpw4f7wPDV
OJWMT4cepcc60bQF3wwxFzHL+B5dzKt+LP1GgEu8Uz2YK1bLpVtfoOBJIUAHCR33
XRe7xYV7g0G28y4zRBqq+JC0fFvs4Yre7GRs3jO2ms50kv7bfKJ5lNEyfEvhPb50
pKsYahTYi0aN7V1luRZ46rqQRwp48TXA6DeZcA+Ruy0Ii5kl/s/kFtQYEQD6EOor
oAKzxosuTY1Vgt7o/o4bARl2wrxB9HHukueT1IlxuwT4lqrAWV/FNceo3n293rfd
oDhMD/UsGORrmBpyX3boUoNmtEi82tEpDvDzRBGv60isUICZJaIlvtO+0FqSt9Vy
/f7DC2C5P2amd9tXYBookcyf4GT9ln6IAr7A69DuybPtPfE+Yh8fuV6ePMB3HJ4q
VkbmgeCRsS798djONnppjJLYriw0M9Z+FQVNTvgwbCDESXEbLkKCTii+4gqCe0cR
0cKhEaBJoK6zLUoOVT4M
=xsfD
-----END PGP SIGNATURE-----

--mojUlQ0s9EVzWg2t--
