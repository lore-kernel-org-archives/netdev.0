From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND patch 2.6.25-rc2-git] rndis_host:  fix transfer size
 negotiation
Date: Mon, 17 Mar 2008 08:08:50 -0400
Message-ID: <47DE5F52.1010602@garzik.org>
References: <200803131556.36960.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network development list <netdev@vger.kernel.org>,
	Jean-Christophe Dubois <jcd@tribudubois.net>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42329 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781AbYCQMIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:08:52 -0400
In-Reply-To: <200803131556.36960.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> From: Jean-Christophe Dubois <jcd@tribudubois.net>
> 
> This patch should resolve a problem that's troubled support for
> some RNDIS peripherals.  It seems to have boiled down to using a
> variable to establish transfer size limits before it was assigned,
> which caused those devices to fallback to a default "jumbogram"
> mode we don't support.  Fix by assigning it earlier for RNDIS.
> 
> Signed-off-by: Jean-Christophe Dubois <jcd@tribudubois.net>
> [ cleanups ]
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> ---
> This bugfix should be merged before 2.6.25-final.
> 
>  drivers/net/usb/rndis_host.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)

applied


