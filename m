From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [RFC V2 PATCH 01/25] net: introduce NET policy
Date: Thu, 4 Aug 2016 13:09:24 -0700
Message-ID: <3823555d-91bf-cdef-95d0-8a22235bb96d@infradead.org>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
 <1470339389-8542-2-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470339389-8542-2-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/16 12:36, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
> 
> This patch introduce NET policy subsystem. If proc is supported in the
> system, it creates netpolicy node in proc system.
> 
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  include/linux/netdevice.h   |   7 +++
>  include/net/net_namespace.h |   3 ++
>  net/Kconfig                 |   7 +++
>  net/core/Makefile           |   1 +
>  net/core/netpolicy.c        | 128 ++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 146 insertions(+)
>  create mode 100644 net/core/netpolicy.c

> diff --git a/net/Kconfig b/net/Kconfig
> index c2cdbce..00552ba 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -205,6 +205,13 @@ source "net/bridge/netfilter/Kconfig"
>  
>  endif
>  
> +config NETPOLICY
> +	depends on NET
> +	bool "Net policy support"
> +	default y
> +	---help---
> +	Net policy support
> +

New kconfig options shouldn't default to y.


-- 
~Randy
