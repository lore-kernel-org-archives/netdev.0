From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: remove duplicate up_write on VF filter_sem
Date: Tue, 20 Jun 2017 15:40:21 -0400 (EDT)
Message-ID: <20170620.154021.1071172261400917698.davem@davemloft.net>
References: <b718af2e-5737-3d98-0f45-cfbb25d43349@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdFTTkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:40:22 -0400
In-Reply-To: <b718af2e-5737-3d98-0f45-cfbb25d43349@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 20 Jun 2017 13:08:51 +0100

> Somehow two copies of the line 'up_write(&vf->efx->filter_sem);' got into
>  efx_ef10_sriov_set_vf_vlan().  This would put the mutex in a bad state and
>  cause all subsequent down attempts to hang.
> 
> Fixes: 671b53eec2ed ("sfc: Ensure down_write(&filter_sem) and up_write() are matched before calling efx_net_open()")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied and queued up for -stable.
