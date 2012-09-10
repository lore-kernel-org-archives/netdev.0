From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ipv6: remove some useless RCU read lock
Date: Mon, 10 Sep 2012 16:31:56 -0400 (EDT)
Message-ID: <20120910.163156.671385158619802264.davem@davemloft.net>
References: <1347281326-26890-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932274Ab2IJUb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 16:31:58 -0400
In-Reply-To: <1347281326-26890-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 10 Sep 2012 20:48:44 +0800

> After this commit:
> 	commit 97cac0821af4474ec4ba3a9e7a36b98ed9b6db88
> 	Author: David S. Miller <davem@davemloft.net>
> 	Date:   Mon Jul 2 22:43:47 2012 -0700
> 
> 	    ipv6: Store route neighbour in rt6_info struct.
> 
> we no longer use RCU to protect route neighbour.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied to net-next, thanks.
