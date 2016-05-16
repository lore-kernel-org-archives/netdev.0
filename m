From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: iwlwifi: mvm: add reorder buffer per queue
Date: Mon, 16 May 2016 14:41:35 +0300
Message-ID: <1463398895.25219.82.camel@coelho.fi>
References: <20160513085428.GA13194@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160513085428.GA13194@mwanda>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 11:54 +0300, Dan Carpenter wrote:
> Hello Sara Sharon,
> 
> The patch b915c10174fb: "iwlwifi: mvm: add reorder buffer per queue"
> from Mar 23, 2016, leads to the following static checker warnings:
> 
> 	drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c:912
> iwl_mvm_rx_mpdu_mq()
> 	error: potential NULL dereference 'sta'.
> 
> 	drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c:912
> iwl_mvm_rx_mpdu_mq()
> 	error: we previously assumed 'sta' could be null (see line 796)

Thanks for the analysis and report, Dan!

I have queued a fix for this through our internal tree.

--
Cheers,
Luca.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
