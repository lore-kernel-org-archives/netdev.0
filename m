From: Debashis Dutt <debdut@gmail.com>
Subject: Re: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Tue, 14 Jun 2011 00:56:22 -0700
Message-ID: <BANLkTi=k-noagFZv-tZbx2FyZ-uBzwP=KA@mail.gmail.com>
References: <cover.1308024069.git.joe@perches.com>
	<486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Divy Le Ray <divy@chelsio.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jon Mason <jdmason@kudzu.us>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniele Venzano <venza@brownhat
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/bna/bfa_cee.c b/drivers/net/bna/bfa_cee.c
> index f7b789a..dcfbf08 100644
> --- a/drivers/net/bna/bfa_cee.c
> +++ b/drivers/net/bna/bfa_cee.c
> @@ -236,7 +236,7 @@ static void
> =A0bfa_cee_hbfail(void *arg)
> =A0{
> =A0 =A0 =A0 =A0struct bfa_cee *cee;
> - =A0 =A0 =A0 cee =3D (struct bfa_cee *) arg;
> + =A0 =A0 =A0 cee =3D arg;
>
> =A0 =A0 =A0 =A0if (cee->get_attr_pending =3D=3D true) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cee->get_attr_status =3D BFA_STATUS_FA=
ILED;
> diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
> index bbd39dc..3c47dc5 100644
> --- a/drivers/net/bna/cna.h
> +++ b/drivers/net/bna/cna.h
> @@ -74,7 +74,7 @@ typedef struct mac { u8 mac[MAC_ADDRLEN]; } mac_t;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bfa_q_next(_q) =3D bfa_q_next(*((struc=
t list_head **) _qe)); \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bfa_q_qe_init(*((struct list_head **) =
_qe)); =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0} else { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *((struct list_head **) (_qe)) =3D (str=
uct list_head *) NULL; \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *((struct list_head **)(_qe)) =3D NULL;=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 \
> =A0}
>

"bna" patches look good.

Thanks
--Debashis
