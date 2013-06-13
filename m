From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, resend] xen-netback: don't de-reference vif pointer
 after having called xenvif_put()
Date: Thu, 13 Jun 2013 01:25:44 -0700 (PDT)
Message-ID: <20130613.012544.109038934924591549.davem@davemloft.net>
References: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
	<20130611.020136.1037505762134627955.davem@davemloft.net>
	<51B7116202000078000DD069@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611Ab3FMIZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:25:51 -0400
In-Reply-To: <51B7116202000078000DD069@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Tue, 11 Jun 2013 11:00:34 +0100

> When putting vif-s on the rx notify list, calling xenvif_put() must be
> deferred until after the removal from the list and the issuing of the
> notification, as both operations dereference the pointer.
> 
> Changing this got me to notice that the "irq" variable was effectively
> unused (and was of too narrow type anyway).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
