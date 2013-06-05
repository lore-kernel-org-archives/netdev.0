From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: don't de-reference vif pointer after
 having called xenvif_put()
Date: Wed, 5 Jun 2013 16:13:31 +0100
Message-ID: <1370445211.24512.196.camel@zakaz.uk.xensource.com>
References: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, xen-devel <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:64344 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122Ab3FEPNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 11:13:33 -0400
In-Reply-To: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 15:03 +0100, Jan Beulich wrote:
> When putting vif-s on the rx notify list, calling xenvif_put() must be
> deferred until after the removal from the list and the issuing of the
> notification, as both operations dereference the pointer.
> 
> Changing this got me to notice that the "irq" variable was effectively
> unused (and was of too narrow type anyway).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
