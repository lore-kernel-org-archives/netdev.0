From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH next v3 0/2] Rename WORD_TRUNC/ROUND macros and use them
Date: Wed, 21 Sep 2016 11:37:52 -0400
Message-ID: <20160921153751.GA13620@hmsreliant.think-freely.org>
References: <cover.1474457954.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@ACULAB.COM>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57919 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935862AbcIUPiJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:38:09 -0400
Content-Disposition: inline
In-Reply-To: <cover.1474457954.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 08:45:54AM -0300, Marcelo Ricardo Leitner wrote:
> This patchset aims to rename these macros to a non-confusing name, as
> reported by David Laight and David Miller, and to update all remaining
> places to make use of it, which was 1 last remaining spot.
> 
> v3:
> - Name it SCTP_PAD4 instead of SCTP_ALIGN4, as suggested by David Laight
> v2:
> - fixed 2nd patch summary
> 
> Details on the specific changelogs.
> 
> Thanks!
> 
> Marcelo Ricardo Leitner (2):
>   sctp: rename WORD_TRUNC/ROUND macros
>   sctp: make use of WORD_TRUNC macro
> 
>  include/net/sctp/sctp.h  | 10 +++++-----
>  net/netfilter/xt_sctp.c  |  2 +-
>  net/sctp/associola.c     |  2 +-
>  net/sctp/chunk.c         | 13 +++++++------
>  net/sctp/input.c         |  8 ++++----
>  net/sctp/inqueue.c       |  2 +-
>  net/sctp/output.c        | 12 ++++++------
>  net/sctp/sm_make_chunk.c | 28 ++++++++++++++--------------
>  net/sctp/sm_statefuns.c  |  6 +++---
>  net/sctp/transport.c     |  4 ++--
>  net/sctp/ulpevent.c      |  4 ++--
>  11 files changed, 46 insertions(+), 45 deletions(-)
> 
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
