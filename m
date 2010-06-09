From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2 -next] niu: always include of_device.h
Date: Wed, 9 Jun 2010 17:45:54 -0600
Message-ID: <AANLkTikuIgeSMC5_IzAQGEQRso4udBvBGPcioAiArWb5@mail.gmail.com>
References: <20100609133443.38f1f957.sfr@canb.auug.org.au>
	<20100609103657.66252a27.randy.dunlap@oracle.com> <20100609.110638.112605100.davem@davemloft.net>
	<20100609154409.bf024c0c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100609154409.bf024c0c.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 9, 2010 at 4:44 PM, Randy Dunlap <randy.dunlap@oracle.com> =
wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> The niu driver uses struct of_device when built on any arch, not
> only SPARC64, so always #include <linux/of_device.h>.
>
> drivers/net/niu.c:9700: warning: 'struct of_device' declared inside p=
arameter list
> drivers/net/niu.c:9700: warning: its scope is only this definition or=
 declaration, which is probably not what you want
> drivers/net/niu.c:9716: warning: assignment from incompatible pointer=
 type
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: =A0 =A0 Grant Likely <grant.likely@secretlab.ca>
> Cc: =A0 =A0 Dave Miller <davem@davemloft.net>
> ---
> =A0drivers/net/niu.c | =A0 =A03 ---

Looks okay to me (but I haven't build tested it yet).  The bulk of
of_device.h is compiled out when CONFIG_OF_DEVICE is not selected.

David, are you okay with me taking this via my tree as it depends on
Randy's other patch?

Thanks,
g.


> =A01 file changed, 3 deletions(-)
>
> --- linux-next-20100609.orig/drivers/net/niu.c
> +++ linux-next-20100609/drivers/net/niu.c
> @@ -28,10 +28,7 @@
> =A0#include <linux/slab.h>
>
> =A0#include <linux/io.h>
> -
> -#ifdef CONFIG_SPARC64
> =A0#include <linux/of_device.h>
> -#endif
>
> =A0#include "niu.h"
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
