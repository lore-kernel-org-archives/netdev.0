From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Only add l3mdev oif to dst lookups
Date: Wed, 17 Aug 2016 19:31:14 -0400 (EDT)
Message-ID: <20160817.193114.794021773593737364.davem@davemloft.net>
References: <1471229576-29981-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbcHQXbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:31:16 -0400
In-Reply-To: <1471229576-29981-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 14 Aug 2016 19:52:56 -0700

> Subash reported that commit 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> broke a wifi use case that uses fib rules and xfrms. The intent of
> 42a7b32b73d6 was driven by VRFs with IPsec. As a compromise relax the
> use of oif in xfrm lookups to L3 master devices only (ie., oif is either
> an L3 master device or is enslaved to a master device).
> 
> Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Steffen, please pick this up.

Thank you.
