From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] gianfar: fix compile warning
Date: Tue, 04 Dec 2007 15:07:01 -0500
Message-ID: <4755B365.1010108@pobox.com>
References: <20071202050927.8827.27154.stgit@trillian.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	galak@kernel.crashing.org, afleming@freescale.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53404 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592AbXLDUHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 15:07:10 -0500
In-Reply-To: <20071202050927.8827.27154.stgit@trillian.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> 
> Eliminate an uninitialized variable warning.  The code is correct, but
> a pointer to the automatic variable 'addr' is passed to dma_alloc_coherent.
> Since addr has never been initialized, and the compiler doesn't know
> what dma_alloc_coherent will do with it, it complains.
> 
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
> 
> Jeff, this one should go in for 2.6.24

applied #upstream-fixes


