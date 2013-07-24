From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 0/7] net: introduce generic type and helpers
 for IP address
Date: Wed, 24 Jul 2013 14:28:17 -0700 (PDT)
Message-ID: <20130724.142817.216302535679937307.davem@davemloft.net>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3GXV2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 17:28:18 -0400
In-Reply-To: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 22 Jul 2013 15:05:06 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> As IPv6 becomes popular, more and more subsystems begin to support IPv6,
> therefore we need a generic IP address type, in case of duplicates.
> Also we will also need some helpers to compare, print, check the generic
> IP address.
> 
> This patchset introduce a new type union inet_addr as a union of IPv4
> and IPv6 address, and some helper functions that will be used by existing
> code and in the future VXLAN module.
> 
> However, due to ABI limit, we still can't convert union nf_inet_addr
> to union inet_addr.
> 
> Signed-off-by: Cong Wang <amwang@redhat.com>

I'm sorry I really don't like these changes at all.

You're creating bloat in places that don't need a full sockaddr_in{,6}.

There is a reason some of these pieces of code used custom types, to
minimize the overhead.

I'm not applying these patches, sorry.
