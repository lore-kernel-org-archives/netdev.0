From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: transition to CLOSED when removing
 a VIF
Date: Tue, 08 Oct 2013 21:34:52 -0400 (EDT)
Message-ID: <20131008.213452.1273097532081875318.davem@davemloft.net>
References: <1381150519-14557-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, netdev@vger.kernel.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	Paul.Durrant@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962Ab3JIBe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 21:34:56 -0400
In-Reply-To: <1381150519-14557-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Mon, 7 Oct 2013 13:55:19 +0100

> From: David Vrabel <david.vrabel@citrix.com>
> 
> If a guest is destroyed without transitioning its frontend to CLOSED,
> the domain becomes a zombie as netback was not grant unmapping the
> shared rings.
> 
> When removing a VIF, transition the backend to CLOSED so the VIF is
> disconnected if necessary (which will unmap the shared rings etc).
> 
> This fixes a regression introduced by
> 279f438e36c0a70b23b86d2090aeec50155034a9 (xen-netback: Don't destroy
> the netdev until the vif is shut down).
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks.
