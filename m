From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] driver: macvlan: Remove duplicated IFF_UP
 condition check in macvlan_forward_source
Date: Mon, 21 Nov 2016 11:59:08 -0500 (EST)
Message-ID: <20161121.115908.2164465813816317675.davem@davemloft.net>
References: <1479687998-456-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53804 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753309AbcKUQ7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 11:59:10 -0500
In-Reply-To: <1479687998-456-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Mon, 21 Nov 2016 08:26:38 +0800

> From: Gao Feng <gfree.wind@gmail.com>
> 
> The function macvlan_forward_source_one has already checked the flag
> IFF_UP, so needn't check it outside in macvlan_forward_source too.
> 
> Signed-off-by: Gao Feng <gfree.wind@gmail.com>
> ---
>  v2: Remove the IFF_UP check in macvlan_forward_source instead of macvlan_forward_source_one
>  v1: Initial patch

Applied.
