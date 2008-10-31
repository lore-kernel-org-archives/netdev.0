From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/7] skge: adapt skge to use reworked PCI PM
Date: Fri, 31 Oct 2008 00:55:27 -0400
Message-ID: <490A8FBF.5050304@garzik.org>
References: <200810292122.m9TLMFuV020166@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rjw@sisk.pl, jbarnes@virtuousgeek.org,
	shemminger@linux-foundation.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52395 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504AbYJaEzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:55:32 -0400
In-Reply-To: <200810292122.m9TLMFuV020166@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Adapt the skge driver to the reworked PCI PM
> 
> * Use device_set_wakeup_enable() and friends as needed
> * Remove an open-coded reference to the standard PCI PM registers
> * Use pci_prepare_to_sleep() and pci_back_from_sleep() in the
>   ->suspend() and ->resume() callbacks
> * Use the observation that it is sufficient to call pci_enable_wake()
>   once, unless it fails
> 
> Tested on Asus L5D (Yukon-Lite rev 7).
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/skge.c |   38 +++++++++++---------------------------

applied


