From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 7/7] e100: adapt to the reworked PCI PM
Date: Fri, 31 Oct 2008 00:55:37 -0400
Message-ID: <490A8FC9.2070408@garzik.org>
References: <200810292122.m9TLMIa9020213@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rjw@sisk.pl, elendil@planet.nl,
	jbarnes@virtuousgeek.org, jeffrey.t.kirsher@intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52407 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbYJaEzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:55:41 -0400
In-Reply-To: <200810292122.m9TLMIa9020213@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> 
> Adapt the e100 driver to the reworked PCI PM
> 
> * Use the observation that it is sufficient to call pci_enable_wake()
>   once, unless it fails
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Tested-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Frans Pop <elendil@planet.nl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/e100.c |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)

applied


