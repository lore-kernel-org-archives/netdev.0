From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: remove excessive logging on MTU
 change
Date: Tue, 29 Nov 2016 20:50:31 -0500 (EST)
Message-ID: <20161129.205031.2039514266183636638.davem@davemloft.net>
References: <20161128172544.2491-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kys@microsoft.com, haiyangz@microsoft.com
To: vkuznets@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcK3Buc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:50:32 -0500
In-Reply-To: <20161128172544.2491-1-vkuznets@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Mon, 28 Nov 2016 18:25:44 +0100

> When we change MTU or the number of channels on a netvsc device we get the
> following logged:
> 
>  hv_netvsc bf5edba8...: net device safe to remove
>  hv_netvsc: hv_netvsc channel opened successfully
>  hv_netvsc bf5edba8...: Send section size: 6144, Section count:2560
>  hv_netvsc bf5edba8...: Device MAC 00:15:5d:1e:91:12 link state up
> 
> This information is useful as debug at most.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Applied, thanks.
