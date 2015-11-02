From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: use l4 hash for locally generated
 multipath flows
Date: Mon, 02 Nov 2015 14:39:02 -0500 (EST)
Message-ID: <20151102.143902.1537936093026010153.davem@davemloft.net>
References: <63c7c10d710fb30e886121ac33ef66cedb101cd9.1446139106.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, pch@ordbogen.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbbKBTjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 14:39:08 -0500
In-Reply-To: <63c7c10d710fb30e886121ac33ef66cedb101cd9.1446139106.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 29 Oct 2015 22:20:40 +0100

> This patch changes how the multipath hash is computed for locally
> generated flows: now the hash comprises l4 information.
> 
> This allows better utilization of the available paths when the existing
> flows have the same source IP and the same destination IP: with l3 hash,
> even when multiple connections are in place simultaneously, a single path
> will be used, while with l4 hash we can use all the available paths.
> 
> v2 changes:
> - use get_hash_from_flowi4() instead of implementing just another l4 hash
>   function
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
