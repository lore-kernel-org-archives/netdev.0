From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: eliminate cached dst leak
Date: Thu, 01 Jun 2017 14:46:48 -0400 (EDT)
Message-ID: <20170601.144648.1946518537495893731.davem@davemloft.net>
References: <20170529172557.7065-1-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751130AbdFASqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 14:46:54 -0400
In-Reply-To: <20170529172557.7065-1-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Mon, 29 May 2017 13:25:57 -0400

> After commit 0c1d70af924b ("net: use dst_cache for vxlan device"),
> cached dst entries could be leaked when more than one remote was
> present for a given vxlan_fdb entry, causing subsequent netns
> operations to block indefinitely and "unregister_netdevice: waiting
> for lo to become free." messages to appear in the kernel log.
> 
> Fix by properly releasing cached dst and freeing resources in this
> case.
> 
> Fixes: commit 0c1d70af924b ("net: use dst_cache for vxlan device")

In the future please do not put that "commit " string there, it's not
needed.

> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied and queued up for -stable, thank you.
