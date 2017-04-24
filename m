From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] nfp: DMA flags, adjust head and fixes
Date: Mon, 24 Apr 2017 14:36:04 -0400 (EDT)
Message-ID: <20170424.143604.1133862806777963968.davem@davemloft.net>
References: <20170423031756.94429-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kubakici@wp.pl, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55998 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172539AbdDXSgG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 14:36:06 -0400
In-Reply-To: <20170423031756.94429-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sat, 22 Apr 2017 20:17:51 -0700

> This series takes advantage of Alex's DMA_ATTR_SKIP_CPU_SYNC to make 
> XDP packet modifications "correct" from DMA API point of view.  It 
> also allows us to parse the metadata before we run XDP at no additional
> DMA sync cost.  That way we can get rid of the metadata memcpy, and 
> remove the last upstream user of bpf_prog->xdp_adjust_head.
> 
> David's patch adds a way to read capabilities from the management
> firmware.
> 
> There are also two net-next fixes.  Patch 4 which fixes what seems to
> be a result of a botched rebase on my part.  Patch 5 corrects locking
> when state of ethernet ports is being refreshed.
> 
> ---
> v3: move the sync from alloc func to the actual give to hw func
> v2: sync rx buffers before giving them to the card (Alex)

Series applied, thanks Jakub.
