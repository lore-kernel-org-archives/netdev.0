From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2 net 0/3] sctp: a bunch of fixes by holding transport
Date: Mon, 31 Oct 2016 09:25:46 -0400
Message-ID: <20161031132546.GA15205@hmsreliant.think-freely.org>
References: <cover.1477916928.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39179 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942920AbcJaN0Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 09:26:16 -0400
Content-Disposition: inline
In-Reply-To: <cover.1477916928.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 08:32:30PM +0800, Xin Long wrote:
> There are several places where it holds assoc after getting transport by
> searching from transport rhashtable, it may cause use-after-free issue.
> 
> This patchset is to fix them by holding transport instead.
> 
> v1->v2:
>   Fix the changelog of patch 2/3
> 
> Xin Long (3):
>   sctp: hold transport instead of assoc in sctp_diag
>   sctp: return back transport in __sctp_rcv_init_lookup
>   sctp: hold transport instead of assoc when lookup assoc in rx path
> 
>  include/net/sctp/sctp.h |  2 +-
>  net/sctp/input.c        | 35 +++++++++++++++++------------------
>  net/sctp/ipv6.c         |  2 +-
>  net/sctp/socket.c       |  5 +----
>  4 files changed, 20 insertions(+), 24 deletions(-)
> 
> -- 
> 2.1.0
> 
> 
Series
Acked-by: Neil Horman <nhorman@tuxdriver.com>
