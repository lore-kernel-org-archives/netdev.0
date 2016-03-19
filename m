From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix too large pskb_may_pull with
 remote checksum
Date: Fri, 18 Mar 2016 22:19:51 -0400 (EDT)
Message-ID: <20160318.221951.56003771293284906.davem@davemloft.net>
References: <fcf7ae744d2ab9fa8e560c37f50fc3f80ff20aa8.1458146074.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcCSCTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 22:19:54 -0400
In-Reply-To: <fcf7ae744d2ab9fa8e560c37f50fc3f80ff20aa8.1458146074.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 16 Mar 2016 17:35:47 +0100

> The vxlan header is pulled at this point, don't include it again in the
> calculation.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Please update the commit log message to explain where that pull
happens.

Thanks.
