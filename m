From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] cpts: Fix missing includes
Date: Sun, 06 Apr 2014 19:47:28 +0200
Message-ID: <53419330.405@redhat.com>
References: <1396805660-9807-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: =?UTF-8?B?VmluY2VudCBTdGVobMOp?= <vincent.stehle@laposte.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1396805660-9807-1-git-send-email-vincent.stehle@laposte.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/06/2014 07:34 PM, Vincent Stehl=C3=A9 wrote:
> The ETH_HLEN and VLAN_HLEN definitions are not in if.h any more. Add =
the
> necessary includes to fix the following compilation errors:
>
>    drivers/net/ethernet/ti/cpts.c: In function =E2=80=98cpts_match=E2=
=80=99:
>    drivers/net/ethernet/ti/cpts.c:266:12: error: =E2=80=98ETH_HLEN=E2=
=80=99 undeclared (first use in this function)
>    drivers/net/ethernet/ti/cpts.c:266:12: note: each undeclared ident=
ifier is reported only once for each function it appears in
>    drivers/net/ethernet/ti/cpts.c:276:23: error: =E2=80=98VLAN_HLEN=E2=
=80=99 undeclared (first use in this function)
>
> Signed-off-by: Vincent Stehl=C3=A9 <vincent.stehle@laposte.net>

Thanks, fix is already in net tree ...

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=3D=
79eb9d28c9b22fa419e2c3f1b2cc6e285720ae41

> diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti=
/cpts.c
> index a3bbf59..2a2f82a 100644
> --- a/drivers/net/ethernet/ti/cpts.c
> +++ b/drivers/net/ethernet/ti/cpts.c
> @@ -19,6 +19,8 @@
>    */
>   #include <linux/err.h>
>   #include <linux/if.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
>   #include <linux/hrtimer.h>
>   #include <linux/module.h>
>   #include <linux/net_tstamp.h>
>
