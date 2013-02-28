From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 3/4] sctp: fix association hangs due to errors when
 reneging events from the ordering queue
Date: Thu, 28 Feb 2013 09:34:05 -0500
Message-ID: <20130228143405.GC23518@shamino.rdu.redhat.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <1361991273-30578-4-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Lee A. Roberts" <lee.roberts@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37494 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab3B1OeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 09:34:13 -0500
Content-Disposition: inline
In-Reply-To: <1361991273-30578-4-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 11:54:32AM -0700, Lee A. Roberts wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
> 
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association reassembly and/or lobby
> (ordering) queues.  Close examination of reassembly queue shows
> missing packets.
> 
> In sctp_ulpq_renege_list(), events being reneged from the
> ordering queue may correspond to multiple TSNs.  Identify
> all affected packets; sum freed space and renege from the
> tsnmap.
> 
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
