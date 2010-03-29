From: =?UTF-8?B?VGhvbWFzIE3DvGxsZXI=?= <thomas@mathtm.de>
Subject: Re: [PATCH next-next-2.6] virtio_net: missing sg_init_table
Date: Mon, 29 Mar 2010 21:31:28 +0200
Message-ID: <4BB10010.5060505@mathtm.de>
References: <1269887518.13277.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269887518.13277.13.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 29.03.2010 20:31, schrieb Shirley Ma:
> Add missing sg_init_table for sg_set_buf in virtio_net.
>=20
> Reported-by: Thomas M=C3=BCller <thomas@mathtm.de>
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

I've just tested the patch and it works fine, so I guess you can add a
Tested-by: Thomas M=C3=BCller <thomas@mathtm.de>
line, if you like.

Thanks,
Thomas


> ---
>  drivers/net/virtio_net.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 25dc77c..3f5be35 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -326,6 +326,7 @@ static int add_recvbuf_small(struct virtnet_info =
*vi, gfp_t gfp)
>  	struct scatterlist sg[2];
>  	int err;
> =20
> +	sg_init_table(sg, 2);
>  	skb =3D netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
>  	if (unlikely(!skb))
>  		return -ENOMEM;
> @@ -351,6 +352,7 @@ static int add_recvbuf_big(struct virtnet_info *v=
i, gfp_t gfp)
>  	char *p;
>  	int i, err, offset;
> =20
> +	sg_init_table(sg, MAX_SKB_FRAGS + 2);
>  	/* page in sg[MAX_SKB_FRAGS + 1] is list tail */
>  	for (i =3D MAX_SKB_FRAGS + 1; i > 1; --i) {
>  		first =3D get_a_page(vi, gfp);
>=20
>=20
