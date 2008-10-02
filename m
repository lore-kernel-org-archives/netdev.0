From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: atl2 network driver status
Date: Thu, 2 Oct 2008 18:35:03 -0500
Message-ID: <20081002183503.73674682@osprey.hogchain.net>
References: <20081002230246.GA11570@kroah.com>
	<20081002181731.6b8f563d@osprey.hogchain.net>
	<20081002232148.GA20003@kroah.com>
	<20081002182943.0264f7fa@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jcliburn@gmail.com>, xiong.huang@atheros.com,
	csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:2081 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756144AbYJBXfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 19:35:16 -0400
Received: by el-out-1112.google.com with SMTP id z25so271329ele.1
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 16:35:14 -0700 (PDT)
In-Reply-To: <20081002182943.0264f7fa@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2008 18:29:43 -0500
Jay Cliburn <jcliburn@gmail.com> wrote:

> On Thu, 2 Oct 2008 16:21:48 -0700
> Greg KH <greg@kroah.com> wrote:
> 
> > On Thu, Oct 02, 2008 at 06:17:31PM -0500, Jay Cliburn wrote:
> > > On Thu, 2 Oct 2008 16:02:46 -0700
> > > Greg KH <greg@kroah.com> wrote:
> > > 
> > > > Hi,
> > > > 
> > > > In looking for drivers to add to drivers/staging/ I ran across
> > > > the atl2 driver that is currently in the Fedora and Ubuntu
> > > > kernel trees.
> > > > 
> > > > This driver doesn't look to be scheduled for inclusion in the
> > > > upstream netdev git tree for submission for 2.6.28, is there any
> > > > reason why it is still out-of-the-tree?
> > > 
> > > Hi Greg,
> > > 
> > > It's in net-next-2.6.
> > > 
> > > http://marc.info/?l=linux-netdev&m=122144021209242&w=2
> > 
> > Nice, so that means it's going to be in 2.6.28?
> 
> I think so.  As I understand it, net-next-2.6 is Dave Miller's git
> tree for stuff destined for 2.6.28.

Yep, here it is: Dave's description of his two main trees.

So atl2 will be in 2.6.28.



Date: Sat, 19 Apr 2008 17:35:10 -0700 (PDT)
From: David Miller <davem@davemloft.net>
To: sfr@canb.auug.org.au
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
Subject: New GIT net tree naming...



Based upon feedback from Andrew and others I'm now starting
to use a new naming scheme for my GIT trees:

For changes against Linus's current tree:

   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

For development meant to be merged in the next merge
window we have:

   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git

Andrew/Stephen, let me know if this works for you.  This way
the tree names will never change.
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
