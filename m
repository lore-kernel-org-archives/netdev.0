From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH V2] net/stmmac: Move "#include <linux/platform_device.h>"
 to linux/stmmac.h
Date: Tue, 03 May 2011 07:36:55 +0200
Message-ID: <4DBF9477.5070302@st.com>
References: <51e0617ee964ae60313a99804f4842ac6e96c129.1304397312.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, shiraz.hashim@st.com,
	armando.visconti@st.com, deepak.sikri@st.com,
	viresh.linux@gmail.com
To: Viresh Kumar <viresh.kumar@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:38585 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751219Ab1ECFhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 01:37:06 -0400
In-Reply-To: <51e0617ee964ae60313a99804f4842ac6e96c129.1304397312.git.viresh.kumar@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/2011 6:36 AM, Viresh Kumar wrote:
> stmmac.h uses struct platform_device and doesn't include
> <linux/platform_device.h>. Whereas drivers/net/stmmac/stmmac.h includ=
es it, but
> doesn't directly use it. And so we get following compilation warning =
while using
> this file:
> 	warning: =E2=80=98struct platform_device=E2=80=99 declared inside pa=
rameter list
>=20
> This patch includes <linux/platform_device.h> in linux/stmmac.h and r=
emoves it
> from drivers/net/stmmac/stmmac.h
>=20
> Signed-off-by: Viresh Kumar <viresh.kumar@st.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/stmmac/stmmac.h |    1 -
>  include/linux/stmmac.h      |    2 ++
>  2 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.=
h
> index 5f06c47..2b076b3 100644
> --- a/drivers/net/stmmac/stmmac.h
> +++ b/drivers/net/stmmac/stmmac.h
> @@ -21,7 +21,6 @@
>  ********************************************************************=
***********/
> =20
>  #define DRV_MODULE_VERSION	"Nov_2010"
> -#include <linux/platform_device.h>
>  #include <linux/stmmac.h>
> =20
>  #include "common.h"
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index f29197a..9529e49 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -26,6 +26,8 @@
>  #ifndef __STMMAC_PLATFORM_DATA
>  #define __STMMAC_PLATFORM_DATA
> =20
> +#include <linux/platform_device.h>
> +
>  /* platform data for platform device structure's platform_data field=
 */
> =20
>  /* Private data for the STM on-board ethernet driver */

