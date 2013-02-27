From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 0/4] sctp: fix association hangs due to reassembly/ordering
 logic
Date: Wed, 27 Feb 2013 15:13:57 -0500
Message-ID: <512E6905.2020808@redhat.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com> <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Lee A. Roberts" <lee.roberts@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab3B0UOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 15:14:02 -0500
In-Reply-To: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 01:54 PM, Lee A. Roberts wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
>
> This series of patches resolves several SCTP association hangs observed during
> SCTP stress testing.  Observable symptoms include communications hangs with
> data being held in the association reassembly and/or lobby (ordering) queues.
> Close examination of reassembly/ordering queues may show either duplicated
> or missing packets.

Hi Lee

What changed in this series?  I looked through and they don't look 
different from the prior version?

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
