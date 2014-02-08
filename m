From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 01/13] net: Mark function as static in 9p/client.c
Date: Sat, 8 Feb 2014 12:04:12 -0800
Message-ID: <20140208200412.GA20885@leaf>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 09, 2014 at 01:17:21AM +0530, Rashika Kheria wrote:
> Mark function as static in net/9p/client.c because it is not used
> outside this file.
>=20
> This eliminates the following warning in net/9p/client.c:
> net/9p/client.c:207:18: warning: no previous prototype for =E2=80=98p=
9_fcall_alloc=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

>  net/9p/client.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/9p/client.c b/net/9p/client.c
> index a5e4d2d..9186550 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -204,7 +204,7 @@ free_and_return:
>  	return ret;
>  }
> =20
> -struct p9_fcall *p9_fcall_alloc(int alloc_msize)
> +static struct p9_fcall *p9_fcall_alloc(int alloc_msize)
>  {
>  	struct p9_fcall *fc;
>  	fc =3D kmalloc(sizeof(struct p9_fcall) + alloc_msize, GFP_NOFS);
> --=20
> 1.7.9.5
>=20
