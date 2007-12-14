From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e100: free IRQ to remove warningwhenrebooting
Date: Fri, 14 Dec 2007 15:27:30 -0500
Message-ID: <4762E732.5070107@garzik.org>
References: <20071213003042.1895.34327.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	ianw@gelato.unsw.edu.au
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42991 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755734AbXLNU1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 15:27:34 -0500
In-Reply-To: <20071213003042.1895.34327.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> Adapted from Ian Wienand <ianw@gelato.unsw.edu.au>
> 
> Explicitly free the IRQ before removing the device to remove a
> warning "Destroying IRQ without calling free_irq"
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Ian Wienand <ianw@gelato.unsw.edu.au>
> ---
> 
>  drivers/net/e100.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)

applied #upstream-fixes


