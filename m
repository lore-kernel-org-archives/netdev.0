From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ixgbe: flush when in xmit_more mode and
 under descriptor pressure
Date: Wed, 27 Aug 2014 23:18:14 -0700 (PDT)
Message-ID: <20140827.231814.2270210172570593864.davem@davemloft.net>
References: <1409074458-17989-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbaH1GSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:18:15 -0400
In-Reply-To: <1409074458-17989-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 26 Aug 2014 19:34:18 +0200

> When xmit_more mode is being used and the ring is about to
> become full or the stack has stopped the ring, enforce a tail
> pointer write to the hw. Otherwise, we could risk a TX hang.
> 
> Code suggested by Alexander Duyck.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  v1->v2:
>   - Worked in Alex' feedback; in accordance w/ Alex, sending out v2
>   - Rerun tests, looks good

Applied, thanks Daniel.

I'll make similar mods to igb and vhost_net soon.
