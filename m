From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v3 0/4] sctp: fix association hangs due to reassembly/ordering
 logic
Date: Thu, 28 Feb 2013 10:07:39 -0500
Message-ID: <512F72BB.30909@gmail.com>
References: <1361991273-30578-1-git-send-email-lee.roberts@hp.com> <1362062250-26749-1-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: "Lee A. Roberts" <lee.roberts@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f54.google.com ([209.85.128.54]:35002 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758113Ab3B1POe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 10:14:34 -0500
In-Reply-To: <1362062250-26749-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 09:37 AM, Lee A. Roberts wrote:
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

My Acks from version 1 still apply.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

>
> Lee A. Roberts (4):
>    sctp: fix association hangs due to off-by-one errors in
>      sctp_tsnmap_grow()
>    sctp: fix association hangs due to reneging packets below the
>      cumulative TSN ACK point
>    sctp: fix association hangs due to errors when reneging events from
>      the ordering queue
>    sctp: fix association hangs due to partial delivery errors
>
>   net/sctp/tsnmap.c   |   13 ++++----
>   net/sctp/ulpqueue.c |   87 +++++++++++++++++++++++++++++++++++++++++----------
>   2 files changed, 78 insertions(+), 22 deletions(-)
>
