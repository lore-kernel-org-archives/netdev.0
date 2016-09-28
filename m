From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net 0/5] sctp: some fixes of prsctp polices
Date: Wed, 28 Sep 2016 08:22:42 -0300
Message-ID: <20160928112242.GA4008@localhost.localdomain>
References: <cover.1475059350.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44932 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752809AbcI1LWq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 07:22:46 -0400
Content-Disposition: inline
In-Reply-To: <cover.1475059350.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 06:46:27PM +0800, Xin Long wrote:
> This patchset is to improve some codes about prsctp polices, and also
> to fix some issues.
> 
> v1->v2:
>   - wrap the check of chunk->sent_count in a macro:
>     sctp_chunk_retransmitted in patch 2/5.
> 
> Xin Long (5):
>   sctp: move sent_count to the memory hole in sctp_chunk
>   sctp: reuse sent_count to avoid retransmitted chunks for RTT
>     measurements
>   sctp: remove prsctp_param from sctp_chunk
>   sctp: change to check peer prsctp_capable when using prsctp polices
>   sctp: remove the old ttl expires policy
> 
>  include/net/sctp/structs.h | 16 ++++------------
>  net/sctp/chunk.c           | 31 ++++++++++---------------------
>  net/sctp/output.c          |  6 ++----
>  net/sctp/outqueue.c        | 16 +++++++---------
>  net/sctp/sm_make_chunk.c   | 15 ---------------
>  5 files changed, 23 insertions(+), 61 deletions(-)
> 

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Thanks
