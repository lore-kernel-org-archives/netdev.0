From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 10/11] rndis_host: increase delay in command response
 loop
Date: Thu, 22 May 2008 06:04:12 -0400
Message-ID: <4835451C.40008@garzik.org>
References: <200805142320.m4ENKGnk026640@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linkfanel@yahoo.fr, davem@davemloft.net,
	david-b@pacbell.net, greg@kroah.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44696 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764567AbYEVKEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:04:15 -0400
In-Reply-To: <200805142320.m4ENKGnk026640@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Pierre Ynard <linkfanel@yahoo.fr>
> 
> Some devices running some WinCE firmware (with SC_* Samsung processors
> according to the SynCE project, verified on a HTC P3600 device) fail to
> register because they apparently need extra time to respond correctly to
> requests.  Increase the existing delay to satisfy them.  Based on code
> from the SynCE project, on a suggestion of David Brownell.
> 
> This patch Works For Me(tm).
> 
> Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>
> Acked-by: David Brownell <david-b@pacbell.net>
> Cc: Greg KH <greg@kroah.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/usb/rndis_host.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


