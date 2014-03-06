From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] chelsio: Use more current logging style
Date: Thu, 06 Mar 2014 01:39:08 -0800
Message-ID: <1394098748.12070.60.camel@joe-AO722>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
	 <1393936917-25847-4-git-send-email-hariprasad@chelsio.com>
	 <1393955035.20435.40.camel@joe-AO722> <531635F4.9050208@cogentembedded.com>
	 <1393961805.20435.49.camel@joe-AO722>
	 <20140306062020.GC23862@hariprasad-pc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, kumaras@chelsio.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, nirranjan@chelsio.com
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0073.hostedemail.com ([216.40.44.73]:54735 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751040AbaCFJjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 04:39:13 -0500
In-Reply-To: <20140306062020.GC23862@hariprasad-pc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-06 at 11:50 +0530, Hariprasad S wrote:
> On Tue, Mar 04, 2014 at 11:36:45 -0800, Joe Perches wrote:
> > On Tue, 2014-03-04 at 23:22 +0300, Sergei Shtylyov wrote:
> > > On 03/04/2014 08:43 PM, Joe Perches wrote:
> > > >> From: Kumar Sanghvi <kumaras@chelsio.com>
> > > >> +		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs"
> > > >> +			" (debug0=%#x, debug11=%#x)\n",
> > > > Probably better with the format coalesced:
> > > > 		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs (debug0=%#x, debug11=%#x)\n",
> > >     Surely better, as otherwise it shouldn't pass scripts/checkpatch.pl.
> > 
> > It'd complain in any case as CH_<LEVEL> macros are 
> > uppercase and checkpatch doesn't know that those are
> > logging uses.
> > 
> > Maybe renaming all the CH_<LEVEL> macros to lower
> > case like this would help.
> > 
> > This also can now use dynamic_debug for the ch_dbg
> > statements and removes the CH_MSG function as it's
> > unused.
> > 
> > From: Joe Perches <joe@perches.com>
> > 
> > Use more standard style lower case logging macros.
> > 
> > Coalesce formats
> > Remove unnecessary periods
> > Enable dynamic debugging and verify debug format/arguments
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> [...] 
> > 
> 
> I don't see this patch in net-next or in the netdev patchwork queue.
> Is the patch lost by any chance? Or I missed something ?

Maybe an ack by someone from Chelsio?

Likely David thought it RFC because of the ongoing
patches from Chelsio with "changes requested".

http://patchwork.ozlabs.org/patch/326462/

It's a trivial bit of code to redo if necessary or
desired after the larger patch set done by you all.

cheers, Joe
