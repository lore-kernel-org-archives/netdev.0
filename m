From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v2 5/9] drivers: net: Put prototype declaration for
 function sbni_probe() in sbni.c
Date: Sat, 14 Dec 2013 12:31:42 -0800
Message-ID: <20131214203142.GG17601@leaf>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
 <dd984c99d43214c39b23f95e9a58f3a675147e69.1386911124.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	Sachin Kamat <sachin.kamat@linaro.org>, netdev@vger.kernel.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dd984c99d43214c39b23f95e9a58f3a675147e69.1386911124.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 14, 2013 at 05:55:42PM +0530, Rashika Kheria wrote:
> This patch declares the prototype for the function sbni_probe() in fi=
le sbni.c.
>=20
> Thus, it also removes the following warning in wan/sbni.c:
> drivers/net/wan/sbni.c:224:12: warning: no previous prototype for =E2=
=80=98sbni_probe=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

>  drivers/net/wan/sbni.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
> index 388ddf6..5061ffd 100644
> --- a/drivers/net/wan/sbni.c
> +++ b/drivers/net/wan/sbni.c
> @@ -221,6 +221,7 @@ static void __init sbni_devsetup(struct net_devic=
e *dev)
>  	dev->netdev_ops =3D &sbni_netdev_ops;
>  }
> =20
> +int __init sbni_probe(int unit);
>  int __init sbni_probe(int unit)
>  {
>  	struct net_device *dev;
> --=20
> 1.7.9.5
>=20
