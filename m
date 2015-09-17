From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-sysfs: get_netdev_queue_index() cleanup
Date: Thu, 17 Sep 2015 16:35:32 -0700 (PDT)
Message-ID: <20150917.163532.426856964505201958.davem@davemloft.net>
References: <1442352480-1311-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: cascardo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbbIQXfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:35:33 -0400
In-Reply-To: <1442352480-1311-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Date: Tue, 15 Sep 2015 18:28:00 -0300

> Redo commit ed1acc8cd8c22efa919da8d300bab646e01c2dce.
> 
> Commit 822b3b2ebfff8e9b3d006086c527738a7ca00cd0 ("net: Add max rate tx queue
> attribute") moved get_netdev_queue_index around, but kept the old version.
> Probably because of a reuse of the original patch from before Eric's change to
> that function.
> 
> Remove one inline keyword, and no need for a loop to find
> an index into a table.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> Fixes: 822b3b2ebfff ("net: Add max rate tx queue attribute")
> Acked-by:  Or Gerlitz <ogerlitz@mellanox.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
