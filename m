From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vlan: use IS_ENABLED()
Date: Sat, 03 Nov 2012 15:03:38 -0400 (EDT)
Message-ID: <20121103.150338.501185798299983644.davem@davemloft.net>
References: <1351567348-15229-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab2KCTDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:03:39 -0400
In-Reply-To: <1351567348-15229-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 30 Oct 2012 11:22:28 +0800

> #if defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE)
> 
> can be replaced by
> 
> #if IS_ENABLED(CONFIG_FOO)
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
