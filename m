From: Jeff Garzik <jeff@garzik.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 16:55:34 -0400
Message-ID: <468571C6.3090305@garzik.org>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jason Lunz <lunz@reflexsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60105 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754707AbXF2Uzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:55:40 -0400
In-Reply-To: <20070629175006.GB3917@falooley.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> What's the prognosis for the 7.5.5-series e1000 reorg going into
> netdev-2.6?


As I have posted previously, I am not keen on merging basically an e1000 
rewrite.  That basically throws away all Internet-wide testing so far. 
The rewrite was not done according to Linux kernel standards (read: 
progression of changes), so any problems will bisect into The Big 
Commit(tm) and go no further.  A rewrite also means the complete driver 
has to be reviewed from scratch, since such a large patch is basically 
impossible to review.  Finally, the rewrite doesn't do much to clean up 
the e1000 driver.

I warned Intel for months not to do things this way, but I guess my 
opinion counts for little :)

	Jeff


