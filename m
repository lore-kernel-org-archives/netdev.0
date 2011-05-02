From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] linux/stmmac.h: include <linux/platform_device.h> to
 remove compilation warning.
Date: Mon, 02 May 2011 14:46:09 +0200
Message-ID: <4DBEA791.4010900@st.com>
References: <2239eca1d15014be7b6d94f883f9492dc1fbc60a.1304317552.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shiraz.hashim@st.com,
	armando.visconti@st.com, deepak.sikri@st.com,
	viresh.linux@gmail.com
To: Viresh Kumar <viresh.kumar@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:46443 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757912Ab1EBNFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 09:05:46 -0400
In-Reply-To: <2239eca1d15014be7b6d94f883f9492dc1fbc60a.1304317552.git.viresh.kumar@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2011 8:30 AM, Viresh Kumar wrote:
> stmmac.h uses struct platform_device and doesn't include
> <linux/platform_device.h>. And so we get following compilation warnin=
g while
> using this file:
> 	warning: =E2=80=98struct platform_device=E2=80=99 declared inside pa=
rameter list
>=20
> This patch includes <linux/platform_device.h> in stmmac.h to remove t=
his warning

Hi Viresh

thanks for the patch that looks good for me.
We could also remove this inclusion (see commit
1f0f63885658889b3bcb8a08fbcb9532f8e536c9) from
drivers/net/stmmac/stmmac.h and keep it in linux/stmmac.h as you sugges=
ted.

What do you think?

Regards
Peppe

> Signed-off-by: Viresh Kumar <viresh.kumar@st.com>
> ---
>  include/linux/stmmac.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index 73d9b4e..d7dfe7d 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -26,6 +26,8 @@
>  #ifndef __STMMAC_PLATFORM_DATA
>  #define __STMMAC_PLATFORM_DATA
> =20
> +#include <linux/platform_device.h>
> +
>  #define STMAC_TYPE_0	0
>  #define STMAC_TYPE_1	1
>  #define STMAC_TYPE_2	2

