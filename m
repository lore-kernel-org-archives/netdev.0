From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2 net-next 0/5] sctp: add support for generating stream
 reconf chunks
Date: Mon, 9 Jan 2017 07:43:25 -0500
Message-ID: <20170109124325.GB20973@hmswarspite.think-freely.org>
References: <cover.1483781759.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46807 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937522AbdAIMo1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 07:44:27 -0500
Content-Disposition: inline
In-Reply-To: <cover.1483781759.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 07, 2017 at 05:42:57PM +0800, Xin Long wrote:
> This patchset is to add some functions to generate stream reconf chunks,
> described in RFC6525 Section 3 and Section 4.
> 
> v1->v2:
>   - put these into a smaller group.
>   - rename some temporary variables in the codes.
>   - rename the titles of the commits and improve some changelogs.
> 
> Xin Long (5):
>   sctp: add a common helper function to generate stream reconf chunk
>   sctp: add support for generating stream reconf ssn reset request chunk
>   sctp: add support for generating stream reconf ssn/tsn reset request
>     chunk
>   sctp: add support for generating stream reconf response chunk
>   sctp: add support for generating stream reconf add streams request
>     chunk
> 
>  include/linux/sctp.h       |  68 ++++++++++++
>  include/net/sctp/sm.h      |  17 ++-
>  include/net/sctp/structs.h |   3 +
>  net/sctp/associola.c       |   1 +
>  net/sctp/sm_make_chunk.c   | 270 +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 358 insertions(+), 1 deletion(-)
> 
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

These all look reasonably good, but it seems before we accept them,
there should be an additional patch that actually makes use of the code.
I presume that is forthcomming?

Neil
