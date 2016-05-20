From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: only deinitialized hash if it
 was initialized
Date: Fri, 20 May 2016 17:42:18 -0400 (EDT)
Message-ID: <20160520.174218.308799409009522232.davem@davemloft.net>
References: <1463583342-25085-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbcETVmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 17:42:24 -0400
In-Reply-To: <1463583342-25085-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 18 May 2016 15:55:42 +0100

> A domain with a frontend that does not implement a control ring has been
> seen to cause a crash during domain save. This was apparently because
> the call to xenvif_deinit_hash() in xenvif_disconnect_ctrl() is made
> regardless of whether a control ring was connected, and hence
> xenvif_hash_init() was called.
> 
> This patch brings the call to xenvif_deinit_hash() in
> xenvif_disconnect_ctrl() inside the if clause that checks whether the
> control ring event channel was connected. This is sufficient to ensure
> it is only called if xenvif_init_hash() was called previously.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

Applied, thanks.
