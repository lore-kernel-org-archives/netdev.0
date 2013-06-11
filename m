From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: don't de-reference vif pointer after
 having called xenvif_put()
Date: Tue, 11 Jun 2013 02:01:36 -0700 (PDT)
Message-ID: <20130611.020136.1037505762134627955.davem@davemloft.net>
References: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab3FKJBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:01:37 -0400
In-Reply-To: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Wed, 05 Jun 2013 15:03:11 +0100

> When putting vif-s on the rx notify list, calling xenvif_put() must be
> deferred until after the removal from the list and the issuing of the
> notification, as both operations dereference the pointer.
> 
> Changing this got me to notice that the "irq" variable was effectively
> unused (and was of too narrow type anyway).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

You've included the commit message, and the patch, twice.  Once inline
and once as an attachment, do not do this.  It makes the patch impossible
to apply when I fetch it out of patchwork.

Please submit it properly.
