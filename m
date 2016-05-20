From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: correct length checks on hash
 copy_ops
Date: Fri, 20 May 2016 10:51:22 -0700 (PDT)
Message-ID: <20160520.105122.1212595607418214946.davem@davemloft.net>
References: <1463557981-17294-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbcETRvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 13:51:24 -0400
In-Reply-To: <1463557981-17294-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 18 May 2016 08:53:01 +0100

> The length checks on the grant table copy_ops for setting hash key and
> hash mapping are checking the local 'len' value which is correct in
> the case of the former but not the latter. This was picked up by
> static analysis checks.
> 
> This patch replaces checks of 'len' with 'copy_op.len' in both cases
> to correct the incorrect check, keep the two checks consistent, and to
> make it clear what the checks are for.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
