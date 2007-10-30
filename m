From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgb: fix TX hangs under heavy load
Date: Tue, 30 Oct 2007 14:33:19 -0400
Message-ID: <472778EF.8080700@garzik.org>
References: <20071030182150.25962.48103.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	andy@greyhouse.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60796 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754285AbXJ3SdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 14:33:21 -0400
In-Reply-To: <20071030182150.25962.48103.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> A merge error occurred where we merged the wrong block here
> in version 1.0.120. The right condition for frags is slightly
> different then for the skb, so account for the difference properly
> and trim the TSO based size right.
> 
> Originally part of a fix reported by IBM to fix TSO hangs on
> pSeries hardware.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> ---
> 
>  drivers/net/ixgb/ixgb_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c

applied


