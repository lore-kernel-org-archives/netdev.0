From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] ixgb: fix TX hangs under heavy load
Date: Tue, 30 Oct 2007 15:28:13 -0400
Message-ID: <20071030192812.GB7195@gospo.rdu.redhat.com>
References: <20071030182150.25962.48103.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60276 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758138AbXJ3T2P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 15:28:15 -0400
Content-Disposition: inline
In-Reply-To: <20071030182150.25962.48103.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 11:21:50AM -0700, Auke Kok wrote:
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

Thanks, Auke and Jesse!
