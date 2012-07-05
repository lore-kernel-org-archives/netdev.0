From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [B.A.T.M.A.N.] [PATCH net] Bug fix for batman-adv 2012-07-06
Date: Fri, 6 Jul 2012 00:51:40 +0200
Message-ID: <20120705225140.GA9745@ritirata.org>
References: <1341528514-27906-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:56397 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2GEWve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 18:51:34 -0400
Content-Disposition: inline
In-Reply-To: <1341528514-27906-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 06, 2012 at 12:48:33 +0200, Antonio Quartulli wrote:
> here I have a fix intended for net/linux-3.5.
 ...


Hello David,

here you have our instructions to resolve the conflicts that you will hit w=
hile
merging net into net-next:




Conflict 1 (bridge_loop_avoidance.c):
<<<<<<<
int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short =
vid)
=3D=3D=3D=3D=3D=3D=3D
int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid,
	   bool is_bcast)
>>>>>>>

resolves to:
int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short =
vid,
		  bool is_bcast)

Conflict 2 (bridge_loop_avoidance.h):
<<<<<<<
int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short =
vid);
int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short =
vid);
int batadv_bla_is_backbone_gw(struct sk_buff *skb,
			      struct batadv_orig_node *orig_node, int hdr_size);
int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offse=
t);
int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *o=
rig);
int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
				   struct batadv_bcast_packet *bcast_packet,
				   int hdr_size);
void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
				    struct batadv_hard_iface *primary_if,
				    struct batadv_hard_iface *oldif);
int batadv_bla_init(struct batadv_priv *bat_priv);
void batadv_bla_free(struct batadv_priv *bat_priv);
=3D=3D=3D=3D=3D=3D=3D
int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid,
	   bool is_bcast);
int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
int bla_is_backbone_gw(struct sk_buff *skb,
		       struct orig_node *orig_node, int hdr_size);
int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
int bla_is_backbone_gw_orig(struct bat_priv *bat_priv, uint8_t *orig);
int bla_check_bcast_duplist(struct bat_priv *bat_priv,
			    struct bcast_packet *bcast_packet, int hdr_size);
void bla_update_orig_address(struct bat_priv *bat_priv,
			     struct hard_iface *primary_if,
			     struct hard_iface *oldif);
int bla_init(struct bat_priv *bat_priv);
void bla_free(struct bat_priv *bat_priv);
>>>>>>>

resolves to:
int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short =
vid,
		  bool is_bcast);
int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short =
vid);
int batadv_bla_is_backbone_gw(struct sk_buff *skb,
			      struct batadv_orig_node *orig_node, int hdr_size);
int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offse=
t);
int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *o=
rig);
int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,=20
				   struct batadv_bcast_packet *bcast_packet,
				   int hdr_size);
void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
				    struct batadv_hard_iface *primary_if,
				    struct batadv_hard_iface *oldif);
int batadv_bla_init(struct batadv_priv *bat_priv);
void batadv_bla_free(struct batadv_priv *bat_priv);


Conflict 3 (bridge_loop_avoidance.h):
<<<<<<<
static inline int batadv_bla_rx(struct batadv_priv *bat_priv,
				struct sk_buff *skb, short vid)
=3D=3D=3D=3D=3D=3D=3D                        =20
static inline int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb,
			 short vid, bool is_bcast)
>>>>>>>

resolves to:
static inline int batadv_bla_rx(struct batadv_priv *bat_priv,
				struct sk_buff *skb, short vid, bool is_bcast)

Conflict 4 (soft-interface.c):
<<<<<<<
	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);
=3D=3D=3D=3D=3D=3D=3D
	bool is_bcast;

	is_bcast =3D (batadv_header->packet_type =3D=3D BAT_BCAST);
>>>>>>>

resolves to:
	bool is_bcast;
	__be16 ethertype =3D __constant_htons(BATADV_ETH_P_BATMAN);

	is_bcast =3D (batadv_header->packet_type =3D=3D BATADV_BCAST);


Conflict 5 (soft-interface.c):
<<<<<<<
	if (batadv_bla_rx(bat_priv, skb, vid))
=3D=3D=3D=3D=3D=3D=3D
	if (bla_rx(bat_priv, skb, vid, is_bcast))
>>>>>>>

resolves to:
	if (batadv_bla_rx(bat_priv, skb, vid, is_bcast))


Wrong merge by git (soft-interface.c):
line 270 must look like this:
	struct batadv_header *batadv_header =3D (struct batadv_header *)skb->data;




--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAk/2GnwACgkQpGgxIkP9cwc5lQCcCxcCLWBxLmT3l2X7B/Nqp2NF
P0gAni3pGLJ9j8WaCkhjdl220l2u3QWZ
=OKRw
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--
