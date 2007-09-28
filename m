From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Fri, 28 Sep 2007 02:28:42 -0700
Message-ID: <20070928022842.8f408d71.akpm@linux-foundation.org>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com>
	<46FB6F1E.8070105@fr.ibm.com>
	<m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>
	<20070927.124552.69400277.davem@davemloft.net>
	<m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
	<46FCC56D.9050600@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50099 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758054AbXI1J2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 05:28:51 -0400
In-Reply-To: <46FCC56D.9050600@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Sep 2007 11:12:13 +0200 Cedric Le Goater <clg@fr.ibm.com> wrote:

> > Cedric made a good point that we will have conflicts of code
> > being added to the same place in nsproxy.c and the like.  So
> > I copied Andrew to give him a heads up.
> 
> here's a suggestion,
> 
> we could keep the net namespace unshare patch out of david's tree,
> let andrew merge and release a new -mm and, then, send the net namespace 
> unshare patch to andrew. that should keep nsproxy out of the andrew's 
> merge challenge. But david's tree will miss the unshare part for a while.

This patch only generates two rejects against the current -mm poop pile.
That's insignificant.  We don't need to do anything special to merge a
little patch like this one.

