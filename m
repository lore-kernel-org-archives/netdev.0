From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/6] i40e: Introduce VF Port
 Representator(VFPR) netdevs.
Date: Thu, 29 Dec 2016 21:52:51 -0500 (EST)
Message-ID: <20161229.215251.689242851887487491.davem@davemloft.net>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
        <1483078863-22026-3-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcL3Cwz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 21:52:55 -0500
In-Reply-To: <1483078863-22026-3-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Date: Thu, 29 Dec 2016 22:20:59 -0800

>  		/* VF resources get allocated during reset */
>  		i40e_reset_vf(&vfs[i], false);
>  
> +		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV)
> +			i40e_alloc_vfpr_netdev(&vfs[i], i);

You aren't checking for, and unwinding from, errors signalled
by i40e_alloc_vfpr_netdev().
