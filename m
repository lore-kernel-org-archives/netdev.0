From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v4 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Wed, 21 Jun 2017 13:10:18 +0300
Message-ID: <20170621101018.GD1248@mtr-leonro.local>
References: <20170620130006.307-1-Yuval.Mintz@cavium.com>
 <20170620.123551.765657502957371421.davem@davemloft.net>
 <CAJ3xEMjyHidoAV9_VPkTM9dPdaXRFt8LmpcV_5iEvYEB+ujSmA@mail.gmail.com>
 <CAJ3xEMhVdmpiGxBb8r0Sx3g_4ej7uhaCf4+qSi3ObMJ=-4ybXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3Pql8miugIZX0722"
Cc: David Miller <davem@davemloft.net>, Yuval.Mintz@cavium.com,
        Linux Netdev List <netdev@vger.kernel.org>,
        Michal.Kalderon@cavium.com,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47556 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752071AbdFUKKW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 06:10:22 -0400
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhVdmpiGxBb8r0Sx3g_4ej7uhaCf4+qSi3ObMJ=-4ybXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3Pql8miugIZX0722
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 12:57:36PM +0300, Or Gerlitz wrote:
> On Wed, Jun 21, 2017 at 12:56 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> > On Tue, Jun 20, 2017 at 7:35 PM, David Miller <davem@davemloft.net> wrote:
> >> From: Yuval Mintz <Yuval.Mintz@cavium.com>
> >> Date: Tue, 20 Jun 2017 15:59:59 +0300
> >>
> >>> Please consider applying this series to `net-next'.
> >>
> >> Series applied, thanks.
>
> Yuval,
>
> It's broke my build
>
> In file included from drivers/net/ethernet/qlogic/qede/qede.h:43,
>                  from drivers/net/ethernet/qlogic/qede/qede_ethtool.c:41:
> ./include/linux/qed/qede_rdma.h:85: error: expected identifier or '('
> before '{' token
> In file included from drivers/net/ethernet/qlogic/qede/qede.h:43,
>                  from drivers/net/ethernet/qlogic/qede/qede_dcbnl.c:13:
> ./include/linux/qed/qede_rdma.h:85: error: expected identifier or '('
> before '{' token
> make[5]: *** [drivers/net/ethernet/qlogic/qede/qede_dcbnl.o] Error 1
>
> here's the fix
>
> diff --git a/include/linux/qed/qede_rdma.h b/include/linux/qed/qede_rdma.h
> index 1348a16..9904617 100644
> --- a/include/linux/qed/qede_rdma.h
> +++ b/include/linux/qed/qede_rdma.h
> @@ -81,7 +81,7 @@ void qede_rdma_dev_remove(struct qede_dev *dev);
>  void qede_rdma_event_changeaddr(struct qede_dev *edr);
>
>  #else
> -static inline int qede_rdma_dev_add(struct qede_dev *dev);
> +static inline int qede_rdma_dev_add(struct qede_dev *dev)
>  {
>         return 0;
>  }


Yeah, Yuval sent it already:
https://patchwork.ozlabs.org/patch/778632/

Thanks

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--3Pql8miugIZX0722
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllKRgoACgkQ5GN7iDZy
WKeOtRAAqT6zMPPcMnPBV151AIuq8f3mEnj50NiYcckSpPLsENJ9yTDqSix/K/m2
JcGQUjAVvXpslUJKWO9jDcRkzBJ3Jt7M4mCt3HTO8RbnCwYfjioD6q78WIGnMy8y
Jxo1XQ9cH+LN+DJQmFP8cGy0x45qiWkmhRkW+vi50jg3fdD01ARrrPYMVZZCPdWr
HZAOsDT6aL3AVDGn6+xYGRAtrX7Sc0SwM3s31q1O2pZRYOzmgvE/6OyAI1c2hI8L
I4Jc15JNfvUjo2ZcJUpo/xA0gmhhdWM31cy0+91cMT7+ef9Q/rvY8bXC9V8QmBUo
oDRVzWxS2lHW+iaduscdHDZewcSC8f/pDXnLJfc3NzJNU6RWjb9lxIYmicc6JX4w
jpZiNHhO+x+lb7T4Owyp2fpXpQPuU2vYldaZYHfadEAMPPGZPEJmWwRxT989xmzF
RUK1pLSR+uacMeXmfNXNkYvhiDcOyIBK2Te+eO879kImj9jyn8xaPY/zoRzbf8SK
UAtmPzfRcE7zc3FWbmp1qBzYvBQ/NhhXpZOZEm4DpOfecQEaw9XE/kSbLLReXW3d
qjYSrGioUqrNEbUfVu8jv7V8vAcO+pXPwKvEybiqCpUn0qE+GekaRiF4RornLf9E
oq4OeiPBtbuZBcmBzV22CTx8q3NXfghdgflt0Q8sqy7wdKZEEYI=
=6nYJ
-----END PGP SIGNATURE-----

--3Pql8miugIZX0722--
