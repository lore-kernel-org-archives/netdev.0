From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 12/18] e1000: #if 0 two functions
Date: Tue, 14 Aug 2007 01:36:20 -0400
Message-ID: <46C13F54.3030508@garzik.org>
References: <200708102105.l7AL5M0O008980@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
To: akpm@linux-foundation.org, auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44509 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932110AbXHNFgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:36:24 -0400
In-Reply-To: <200708102105.l7AL5M0O008980@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Adrian Bunk <bunk@stusta.de>
> 
> e1000_{read,write}_pci_cfg() are no longer used.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Cc: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/e1000/e1000_hw.h   |    2 --
>  drivers/net/e1000/e1000_main.c |    4 ++++
>  2 files changed, 4 insertions(+), 2 deletions(-)

if it's truly dead code in upstream, we should just remove it from e1000


