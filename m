From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Thu, 28 Feb 2013 15:36:34 -0500 (EST)
Message-ID: <20130228.153634.1310286567455843160.davem@davemloft.net>
References: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
	<1362062250-26749-1-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: lee.roberts@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760232Ab3B1Ugj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 15:36:39 -0500
In-Reply-To: <1362062250-26749-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>
Date: Thu, 28 Feb 2013 07:37:26 -0700

> From: "Lee A. Roberts" <lee.roberts@hp.com>
> 
> This series of patches resolves several SCTP association hangs observed during
> SCTP stress testing.  Observable symptoms include communications hangs with
> data being held in the association reassembly and/or lobby (ordering) queues.
> Close examination of reassembly/ordering queues may show either duplicated
> or missing packets.
> 
> In version #2, corrected build failure in initial version of patch series
> due to wrong calling sequence for sctp_ulpq_partial_delivery() being inserted
> in sctp_ulpq_renege().
> 
> In version #3, adjusted patch documentation to be less repetitive.

Series applied, thanks.
