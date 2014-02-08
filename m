From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 02/13] net: Include appropriate header file in
 caif/caif_dev.c
Date: Sat, 8 Feb 2014 12:04:43 -0800
Message-ID: <20140208200443.GB20885@leaf>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
 <30885a464918e0f7cbb55b5c521a048f3e369c27.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <30885a464918e0f7cbb55b5c521a048f3e369c27.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 09, 2014 at 01:19:43AM +0530, Rashika Kheria wrote:
> Include appropriate header file net/caif/caif_dev.h in caif/caif_dev.=
c
> because it has prototype declarations of function defined in
> caif/caif_dev.c.
>=20
> This eliminates the following file in caif/caif_dev.c:
> net/caif/caif_dev.c:303:6: warning: no previous prototype for =E2=80=98=
caif_enroll_dev=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

>  net/caif/caif_dev.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
> index 4dca159..edbca46 100644
> --- a/net/caif/caif_dev.c
> +++ b/net/caif/caif_dev.c
> @@ -22,6 +22,7 @@
>  #include <net/pkt_sched.h>
>  #include <net/caif/caif_device.h>
>  #include <net/caif/caif_layer.h>
> +#include <net/caif/caif_dev.h>
>  #include <net/caif/cfpkt.h>
>  #include <net/caif/cfcnfg.h>
>  #include <net/caif/cfserl.h>
> --=20
> 1.7.9.5
>=20
