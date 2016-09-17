From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: Re: [PATCH net-next v2 3/5] cxgb4: add parser to translate u32
 filters to internal spec
Date: Sat, 17 Sep 2016 14:10:19 +0530
Message-ID: <20160917084018.GA6429@chelsio.com>
References: <cover.1473759872.git.rahul.lakkireddy@chelsio.com>
 <ccd36e66281e2302cb46c7351be22a3ca276c07e.1473759872.git.rahul.lakkireddy@chelsio.com>
 <57DAAFCC.8000207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hariprasad@chelsio.com, leedom@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:48066 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755250AbcIQIlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 04:41:50 -0400
Content-Disposition: inline
In-Reply-To: <57DAAFCC.8000207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 09/15/16, 2016 at 07:27:24 -0700, John Fastabend wrote:
> On 16-09-13 04:42 AM, Rahul Lakkireddy wrote:
> > Parse information sent by u32 into internal filter specification.
> > Add support for parsing several fields in IPv4, IPv6, TCP, and UDP.
> > 
> > Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> > Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> > ---
> 
> Looks good to me. Also curious if you would find it worthwhile to
> have a cls_u32 mode that starts at L2 instead of the IP header? The
> use case would be to use cls_u32 with various encapsulation protocols
> in front of the IP header.
> 
> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>

Thanks for the review John.  Yes, we are also looking for getting u32
to start from L2 header in order to allow matching encapsulation
protocols in front of IP header.

In addition, our hardware also keeps track of per-filter statistics
such as number of times the filter has been hit and number of bytes
that hit the filter. Hence, we are also looking for exposing these
per-filter stats to u32.

Thanks,
Rahul
