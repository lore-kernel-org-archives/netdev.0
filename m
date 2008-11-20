From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pkt_sched: add DRR scheduler
Date: Thu, 20 Nov 2008 11:35:57 +0000
Message-ID: <20081120113557.GA5275@ff.dom.local>
References: <49242217.5030406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:55420 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047AbYKTLgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:36:05 -0500
Received: by ik-out-1112.google.com with SMTP id c29so339847ika.5
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 03:36:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49242217.5030406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19-11-2008 15:26, Patrick McHardy wrote:

...
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 36543b6..ba31fe3 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -194,6 +194,17 @@ config NET_SCH_NETEM
>  
>  	  If unsure, say N.
>  
> +config NET_SCH_DRR
> +	tristate "Deficit round robing scheduler (DRR)"

 -	tristate "Deficit round robing scheduler (DRR)"
 +	tristate "Deficit Round Robin scheduler (DRR)"

> +	help
> +	  Say Y here if you want to use the Deficit round robin (DRR) packet

 -	  Say Y here if you want to use the Deficit round robin (DRR) packet
 +	  Say Y here if you want to use the Deficit Round Robin (DRR) packet

> +	  scheduling algorithm.

Looks OK to me except checkpatch and documentation/example (any... even
at the beginning of the program).

Jarek P.
