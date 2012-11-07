From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 03/12] batman-adv: add UNICAST_4ADDR
	packet type
Date: Wed, 07 Nov 2012 20:25:10 +0100
Message-ID: <2868197.Rr5d6gvmpi@sven-desktop.home.narfation.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
 <1352315502-20324-4-git-send-email-ordex@autistici.org>
 <1403033.aGBWZgaJ6z@sven-desktop.home.narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart42263005.qWjGYca53u";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1403033.aGBWZgaJ6z-1RWNDQYo44h8XcdJbWeDu3TFMtCCXL7YSoIsB4E12gc@public.gmane.org>
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


--nextPart42263005.qWjGYca53u
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Wednesday 07 November 2012 20:17:08 Sven Eckelmann wrote:
> On Wednesday 07 November 2012 20:11:33 Antonio Quartulli wrote:
> > +/**
> > + * struct batadv_unicast_4addr_packet - extended unicast packet
> > + * @u: common unicast packet header
> > + * @src: address of the source
> > + * @subtype: packet subtype
> > + */
> > +struct batadv_unicast_4addr_packet {
> > +       struct batadv_unicast_packet u;
> > +       uint8_t src[ETH_ALEN];
> > +       uint8_t subtype;
> > +       uint8_t reserved;
> > +       /* "4 bytes boundary + 2 bytes" long to make the payload after the
> > +        * following ethernet header again 4 bytes boundary aligned
> > +        */
> > +};
> 
> This doesn't work as you think. Now you have 2 extra padding bytes at the
> end of the batadv_unicast_4addr_packet and therefore make the payload (IPv4
> header..) after the following ethernet header again wrongly aligned.

Sry, my fault. Mixed it up with another packed which had a __be32 included 
(batadv_bcast_packet).

Kind regards,
	Sven
--nextPart42263005.qWjGYca53u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQmrWWAAoJEF2HCgfBJntGlX4P/2MjlqftCahijzjFeaN5W9V7
JqpqFObw5vfI7D6mu3jvLQ/EbxFUPlvcvX+QSVHsSP6UggSJK8/9d0UiVsWaoZQ5
qiiy3bIwAfnwbC9Fvcsr1NcVlUj89akuof2+mBm+BJDcGG39ezWQdf/CFx59r/8g
PY5s90nCkzziVDBAtfBEYoRd4fvFqhe2KL6Xgi81rEv9BtKk+hRFeS7gOs3zE049
4HXS4hc+x5m/rs0ecRD7J5O1qdJAGYQjbQuDvWmxOa2a8MP8EmJ0meNKoDRVxhJ0
9IdGQpqfrxXFcPD/RUjE2UOnVDwcyf5sP3E8StAyYyHqKs3mLbXpMb/3kDye7Zdt
lvXMZwlv+I4y9KpvzRI7nORyT9akMEwgszy5SMjIOeYJOX8aNZFvHo9c0aDbS9sS
ZuYB6nEPGqO4ccscCCngjc2WwdEGa14iWlQndZf2TYheZjgvoMMkE14U7NYV9jfq
B80/5GJjrb1v5S4OURzrKagS2Y4A6xFLAUE+U35qAh7Uwyzu6xb9ZnGdDbA41hgf
HLK+T2nOD4TTUSnxlLPl++trOT24gMoxcnE9C8WxSLWqc1iVN6ydgn4Hsoo/uk1F
CCLL0MKgYn9nX321Ks+isyxUoRMoIQ5//un8eqF9ziqPJN54b4FC1LHVp5VYJQPk
d/au+ETuR4QWG79t3L1A
=szYz
-----END PGP SIGNATURE-----

--nextPart42263005.qWjGYca53u--
