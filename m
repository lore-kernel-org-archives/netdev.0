From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net-next tree
Date: Tue, 25 Oct 2011 19:26:36 +1100
Message-ID: <20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Oct_2011_19_26_36_+1100_5+fykKIOW=qJZ7+d"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mark Einon <mark.einon@gmail.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_Oct_2011_19_26_36_+1100_5+fykKIOW=qJZ7+d
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/et131x/et1310_tx.c drivers/staging/et131x/et131x_netdev.c
between commits afc4b13df143 ("net: remove use of ndo_set_multicast_list
in drivers"), bf3f1a6081aa ("et131x: convert to SKB paged frag API") and
5d6bcdfe38ce ("net: use DMA_x_DEVICE and dma_mapping_error with
skb_frag_dma_map") from the net-next tree and commit d2796743cba2
("staging: et131x: Put all .c files into one big file") from the staging
tree.

The latter removed these files, so I did that but more fixup is proably
needed.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__25_Oct_2011_19_26_36_+1100_5+fykKIOW=qJZ7+d
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOpnK8AAoJEECxmPOUX5FE4DkP/A+8ojZnxf73+gX+05N+PFD4
Fe6VxHQR4eMCVNvY6CKmtCngwMHyDeWqXqSneOSB2bFrVDg6gpMTujMqaceoq4mt
3J1QpZbJ6yGYhkYf3QqC7C5AgEgvThqcRS4C7pLukzNZDno7os26Lp095eIPyJDf
9wAMr1oAn1Q/6Um0uRazC/RRCv0B0RsQGUhFGvua1E3bgKVYzOVmD4kyRGky6CiU
VbUWIa+0pSZ1JaUR1zaHF+N1A/s1gtkVarc0iO7SbifK1x5Wq7e+BA72guTzaDGQ
DMGLeC2C854j+WDbv1yiQ+KwCsyiEjMnITHDGmzVsd8nW3VxA1xg4/hSpQma0ktE
ecQzFgl1R8/7NnT5unTkvTW+tU2dLtsO/y7952aXHLTS5qSImI5fMN2AhHTAD0UE
luUQAx82VYFVwQI5MrYwPkEJkt8ycZ4VtOvlQQ54EFyuW80efF1ZGRB9wtNmgtKf
J5+AHZ6n0EawwdkCpVmTVwiJClIShUgpNlStGVzXTKsmo0wA+j+D9RCYJNcHB3jS
fKTHIjj+VGzDH37R5tznQqPxU9ZafPR91vLadNRizyuHGCwA6sYOsNp8E2DDlaYw
gaPTxSoT7RpcKCIh16bjpijVeBaTXH7FrbPPkGXjTXlbQ0+mJOTuE2ycEp7Vx7GO
idBP6fqx5yZ8ivpBzht/
=Ti4E
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Oct_2011_19_26_36_+1100_5+fykKIOW=qJZ7+d--
