From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] e1000e: Fix jumbo frame receive code.
Date: Mon, 29 Oct 2007 05:47:24 -0400
Message-ID: <4725AC2C.4060709@garzik.org>
References: <20071025205744.32645.59503.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43854 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbXJ2Jr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 05:47:26 -0400
In-Reply-To: <20071025205744.32645.59503.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Fix allocation and freeing of jumbo frames where several bugs
> were recently introduced by cleanups after we forked this code
> from e1000. This moves ps_pages to buffer_info where it really
> belongs and makes it a dynamically allocated array. The penalty
> is not that high since it's allocated outside of the buffer_info
> struct anyway.
> 
> Without this patch all jumbo frames are completely broken and the
> driver panics.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/e1000.h  |    4 +-
>  drivers/net/e1000e/netdev.c |  102 ++++++++++++++++++++++---------------------
>  2 files changed, 54 insertions(+), 52 deletions(-)

applied 1-4 to #upstream-fixes


