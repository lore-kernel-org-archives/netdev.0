From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: reduce maximum GSO size
Date: Wed, 07 Dec 2016 13:14:03 -0500 (EST)
Message-ID: <20161207.131403.2019170607133977153.davem@davemloft.net>
References: <20161206214354.15473-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932166AbcLGSOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:14:05 -0500
In-Reply-To: <20161206214354.15473-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue,  6 Dec 2016 13:43:54 -0800

> Hyper-V (and Azure) support using NVGRE which requires some extra space
> for encapsulation headers. Because of this the largest allowed TSO
> packet is reduced.
> 
> For older releases, hard code a fixed reduced value.  For next release,
> there is a better solution which uses result of host offload
> negotiation.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
> Please queue this for stable as well.

Applied and queued up for -stable, thanks.
