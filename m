From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] Xen-netback: Fix issue caused by using gso_type
 wrongly
Date: Mon, 10 Mar 2014 21:58:26 -0400 (EDT)
Message-ID: <20140310.215826.2152685771330034462.davem@davemloft.net>
References: <1394463514-2979-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, Ian.Campbell@citrix.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com
To: Annie.li@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbaCKB62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 21:58:28 -0400
In-Reply-To: <1394463514-2979-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <Annie.li@oracle.com>
Date: Mon, 10 Mar 2014 22:58:34 +0800

> From: Annie Li <annie.li@oracle.com>
> 
> Current netback uses gso_type to check whether the skb contains
> gso offload, and this is wrong. Gso_size is the right one to
> check gso existence, and gso_type is only used to check gso type.
> 
> Some skbs contains nonzero gso_type and zero gso_size, current
> netback would treat these skbs as gso and create wrong response
> for this. This also causes ssh failure to domu from other server.
> 
> V2: use skb_is_gso function as Paul Durrant suggested
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>

Applied, thank you.
