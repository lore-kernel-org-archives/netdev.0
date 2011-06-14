From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Tue, 14 Jun 2011 10:18:12 +0200
Message-ID: <BANLkTimdj-p9a+615JPe6oUJQqQo4_+-rA@mail.gmail.com>
References: <cover.1308024069.git.joe@perches.com>
	<486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
	David Dillow <dave@thedillows.o
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/6/14 Joe Perches <joe@perches.com>:
> Unnecessary casts of void * clutter the code.

> diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
> index 484f795..658a192 100644
> --- a/drivers/net/sis900.c
> +++ b/drivers/net/sis900.c
> @@ -482,7 +482,7 @@ static int __devinit sis900_probe(struct pci_dev =
*pci_dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -ENOME=
M;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_out_c=
leardev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 sis_priv->tx_ring =3D (BufferDesc *)ring_space=
;
> + =C2=A0 =C2=A0 =C2=A0 sis_priv->tx_ring =3D ring_space;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sis_priv->tx_ring_dma =3D ring_dma;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ring_space =3D pci_alloc_consistent(pci_de=
v, RX_TOTAL_SIZE, &ring_dma);
> @@ -490,7 +490,7 @@ static int __devinit sis900_probe(struct pci_dev =
*pci_dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -ENOME=
M;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_unmap=
_tx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 sis_priv->rx_ring =3D (BufferDesc *)ring_space=
;
> + =C2=A0 =C2=A0 =C2=A0 sis_priv->rx_ring =3D ring_space;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sis_priv->rx_ring_dma =3D ring_dma;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* The SiS900-specific entries in the devi=
ce structure. */

sis900 looks good, too.

--=20
Daniele Venzano
venza@brownhat.org
http://www.brownhat.org
