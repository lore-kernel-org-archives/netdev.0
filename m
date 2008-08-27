From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibm_newemac: Don't call dev_mc_add() before device is
 registered
Date: Wed, 27 Aug 2008 05:56:28 -0400
Message-ID: <48B524CC.6020309@pobox.com>
References: <1219008563.28339.15.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Sebastian Siewior <bigeasy@linutronix.de>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42011 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754961AbYH0J4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:56:31 -0400
In-Reply-To: <1219008563.28339.15.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> We must not call dev_mc_add() from within our HW configure which happens
> before we initialize and register the netdev. Do it in open() instead.
> 
> Thanks to Sebastian Siewior for tracking it down. 
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> This fixes an uninitialized spinlock warning (and possibly more).
> 
> Please apply.

applied


