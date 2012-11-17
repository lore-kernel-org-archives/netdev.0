From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 net-next] sctp: Add support to per-association
 statistics via a new SCTP_GET_ASSOC_STATS call
Date: Sat, 17 Nov 2012 08:20:41 -0500
Message-ID: <20121117132041.GA30406@hmsreliant.think-freely.org>
References: <1352991680-12289-1-git-send-email-michele@acksyn.org>
 <20121116163922.GA9722@hmsreliant.think-freely.org>
 <20121116214742.GH10831@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45123 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab2KQNVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 08:21:00 -0500
Content-Disposition: inline
In-Reply-To: <20121116214742.GH10831@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 16, 2012 at 09:47:42PM +0000, Thomas Graf wrote:
> On 11/16/12 at 11:39am, Neil Horman wrote:
> > Yes, I think this is good, I still don't like the idea of having to do these via
> > an ioctl, but I suppose it fits well enough.
> 
> I'm with you on this. I have started scribbling notes on paper for
> a netlink based stats retriever. We should discuss this at some
> point making sure we get everyone on board with interests in this
> and solve this nice and clean for everyone to enjoy.
> 
Agreed, I was also doodling out some protocol format and kernel API ideas for
this.  We have a short week due to Thanksgiving here next week, but why don't I
email you after the holiday and we can exchange thoughts? I think a netlink
stats protocol would be a great way to solve the process-private/global access
problem.

> I guess the ioctl is the best we can do as long as we don't have
> the above.
> 
Agreed, it will do, and if we do a good job with the kernel API for the netlink
idea above, maybe we can even inherit existing stats transparently.

Neil
