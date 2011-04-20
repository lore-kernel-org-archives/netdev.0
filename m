From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] net: forcedeth: fix compile warning of not used nv_set_tso
 function
Date: Wed, 20 Apr 2011 09:42:15 +0800
Message-ID: <4DAE39F7.1030504@cn.fujitsu.com>
References: <4DAE3768.9030807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: mirq-linux@rere.qmqm.pl, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56350 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754493Ab1DTBqG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 21:46:06 -0400
In-Reply-To: <4DAE3768.9030807@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is against net-next.

Shan Wei wrote, at 04/20/2011 09:31 AM:
> Fix the below compile warning:
> drivers/net/forcedeth.c:4266: warning: =E2=80=98nv_set_tso=E2=80=99 d=
efined but not used
>=20
> commit 569e146 converts forcedeth driver to use hw_features.
> So, implement function of .set_tso is abandoned.
>=20
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  drivers/net/forcedeth.c |   10 ----------
>  1 files changed, 0 insertions(+), 10 deletions(-)
>=20
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index ec9a32d..0e1c76a 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -4263,16 +4263,6 @@ static int nv_nway_reset(struct net_device *de=
v)
>  	return ret;
>  }
> =20
> -static int nv_set_tso(struct net_device *dev, u32 value)
> -{
> -	struct fe_priv *np =3D netdev_priv(dev);
> -
> -	if ((np->driver_data & DEV_HAS_CHECKSUM))
> -		return ethtool_op_set_tso(dev, value);
> -	else
> -		return -EOPNOTSUPP;
> -}
> -
>  static void nv_get_ringparam(struct net_device *dev, struct ethtool_=
ringparam* ring)
>  {
>  	struct fe_priv *np =3D netdev_priv(dev);


--=20

Best Regards
-----
Shan Wei
