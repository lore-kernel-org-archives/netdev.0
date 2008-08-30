From: Bill Fink <billfink@mindspring.com>
Subject: Re: [NET_NEXT PATCH 2/2] pkt_action: add new action skbedit
Date: Fri, 29 Aug 2008 23:13:45 -0400
Message-ID: <20080829231345.d74f139d.billfink@mindspring.com>
References: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
	<20080828011257.7909.78529.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:41189 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753880AbYH3DNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 23:13:53 -0400
In-Reply-To: <20080828011257.7909.78529.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008, Jeff Kirsher wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This new action will have the ability to change the priority and/or
> queue_mapping fields on an sk_buff.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  include/linux/tc_act/tc_skbedit.h |   23 ++++
>  include/net/tc_act/tc_skbedit.h   |   15 +++
>  net/sched/Kconfig                 |   11 ++
>  net/sched/Makefile                |    1 
>  net/sched/act_skbedit.c           |  199 +++++++++++++++++++++++++++++++++++++
>  5 files changed, 249 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/tc_act/tc_skbedit.h
>  create mode 100644 include/net/tc_act/tc_skbedit.h
>  create mode 100644 net/sched/act_skbedit.c

> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index efaa7a7..613823b 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -485,6 +485,17 @@ config NET_ACT_SIMP
>  	  To compile this code as a module, choose M here: the
>  	  module will be called simple.
>  
> +config NET_ACT_SKBEDIT
> +        tristate "SKB Editing"
> +        depends on NET_CLS_ACT
> +        ---help---
> +	  Say Y here to change skb priority or queue_mapping settings.
> +
> +	  If unsure, say N.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called simple.
> +
>  config NET_CLS_IND
>  	bool "Incoming device classification"
>  	depends on NET_CLS_U32 || NET_CLS_FW

I'm rather backlogged on e-mail at the moment, so apologies if someone
else already pointed this out, but I'm guessing there was a copy and
paste error here, as the module shouldn't be called simple (that's for
the preceding NET_ACT_SIMP).

						-Bill
