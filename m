From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next] chelsio: Use more current logging style
Date: Thu, 6 Mar 2014 11:50:21 +0530
Message-ID: <20140306062020.GC23862@hariprasad-pc>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
 <1393936917-25847-4-git-send-email-hariprasad@chelsio.com>
 <1393955035.20435.40.camel@joe-AO722>
 <531635F4.9050208@cogentembedded.com>
 <1393961805.20435.49.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>, <kumaras@chelsio.com>, <dm@chelsio.com>,
	<swise@opengridcomputing.com>, <leedom@chelsio.com>,
	<santosh@chelsio.com>, <nirranjan@chelsio.com>
To: Joe Perches <joe@perches.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29304 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751147AbaCFGPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 01:15:22 -0500
Content-Disposition: inline
In-Reply-To: <1393961805.20435.49.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 04, 2014 at 11:36:45 -0800, Joe Perches wrote:
> On Tue, 2014-03-04 at 23:22 +0300, Sergei Shtylyov wrote:
> > On 03/04/2014 08:43 PM, Joe Perches wrote:
> > >> From: Kumar Sanghvi <kumaras@chelsio.com>
> > >> +		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs"
> > >> +			" (debug0=%#x, debug11=%#x)\n",
> > > Probably better with the format coalesced:
> > > 		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs (debug0=%#x, debug11=%#x)\n",
> >     Surely better, as otherwise it shouldn't pass scripts/checkpatch.pl.
> 
> It'd complain in any case as CH_<LEVEL> macros are 
> uppercase and checkpatch doesn't know that those are
> logging uses.
> 
> Maybe renaming all the CH_<LEVEL> macros to lower
> case like this would help.
> 
> This also can now use dynamic_debug for the ch_dbg
> statements and removes the CH_MSG function as it's
> unused.
> 
> From: Joe Perches <joe@perches.com>
> 
> Use more standard style lower case logging macros.
> 
> Coalesce formats
> Remove unnecessary periods
> Enable dynamic debugging and verify debug format/arguments
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
[...] 
> 

I don't see this patch in net-next or in the netdev patchwork queue.
Is the patch lost by any chance? Or I missed something ?


Thanks,
-Hari.
