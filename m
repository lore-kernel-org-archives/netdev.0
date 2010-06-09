From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2 -next] of_device.h: provide struct of_device even when
	not enabled
Date: Wed, 9 Jun 2010 17:47:50 -0600
Message-ID: <AANLkTimEovLvQdvrzu37L8zFxZwvUDlGwtVhO4tR2Hwd@mail.gmail.com>
References: <20100609133443.38f1f957.sfr@canb.auug.org.au>
	<20100609103657.66252a27.randy.dunlap@oracle.com> <20100609.110638.112605100.davem@davemloft.net>
	<20100609154405.20095178.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100609154405.20095178.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 9, 2010 at 4:44 PM, Randy Dunlap <randy.dunlap@oracle.com> =
wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Drivers may use struct of_device (struct platform_device), even when
> CONFIG_OF_DEVICE is not enabled, so minimally provide that struct
> for that kconfig case.
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: =A0 =A0 Grant Likely <grant.likely@secretlab.ca>
> Cc: =A0 =A0 Dave Miller <davem@davemloft.net>
> ---
> =A0include/linux/of_device.h | =A0 =A04 ++++
> =A01 file changed, 4 insertions(+)
>
> --- linux-next-20100609.orig/include/linux/of_device.h
> +++ linux-next-20100609/include/linux/of_device.h
> @@ -47,6 +47,10 @@ extern ssize_t of_device_get_modalias(st
>
> =A0extern int of_device_uevent(struct device *dev, struct kobj_uevent=
_env *env);
>
> +#else
> +
> +#include <linux/platform_device.h>
> +#define of_device platform_device

I should probably just move these 2 lines out of the #if/else/endif
block entirely.  I'll make that change and test it out.

g.
