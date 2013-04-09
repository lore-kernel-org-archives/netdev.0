From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Tue, 09 Apr 2013 13:16:14 -0400 (EDT)
Message-ID: <20130409.131614.992928831484310781.davem@davemloft.net>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759921Ab3DIRQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 13:16:16 -0400
In-Reply-To: <1365501445-9712-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue,  9 Apr 2013 17:57:25 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This reverts commit 9dcc71e1fdbb7aa10d92a3d35e8a201adc84abd0.
> It apparently breaks my vxlan tests between different namespaces.
> 
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

How about you simply updating the network namespace attached to the
packet (or whatever piece of state isn't set properly) rather than a
complete revert of his change?

I'm not applying this until you attempt this or the original author
has an opportunity to address this.
