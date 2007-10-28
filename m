From: Bernhard Walle <bwalle@suse.de>
Subject: Re: [PATCH] proc_fs.h redux
Date: Sun, 28 Oct 2007 14:25:08 +0100
Message-ID: <20071028132508.GA28951@suse.de>
References: <20071027194758.GD9816@martell.zuzino.mipt.ru> <1193524804.26695.103.camel@localhost> <20071028103415.GA12554@flint.arm.linux.org.uk> <20071028115952.GA18479@suse.de> <20071028130429.GC12554@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, akpm@osdl.org,
	torvalds@osdl.org
To: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:55760 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbXJ1NZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 09:25:12 -0400
Content-Disposition: inline
In-Reply-To: <20071028130429.GC12554@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Russell King <rmk+lkml@arm.linux.org.uk> [2007-10-28 14:04]:
> On Sun, Oct 28, 2007 at 12:59:52PM +0100, Bernhard Walle wrote:
> > * Russell King <rmk+lkml@arm.linux.org.uk> [2007-10-28 11:34]:
> > > 
> > > If you go down that route, you end up with _lots_ of circular
> > > dependencies - header file X needs Y needs Z which needs X.  We've
> > > been there, several times.  It very quickly becomes quite
> > > unmaintainable - you end up with hard to predict behaviour from
> > > include files.
> > > 
> > > The only realistic solution is to use forward declarations.
> > 
> > In header files, yes. But that's not true for implementation files.
> 
> I don't think that needs saying - it's quite obvious.  You can't
> access the contents of structures without their definitions being
> available.

Of course. But there might be the case where an implementation file
doesn't access the structure itself but just passes the pointer to
some other function (which is implemented in another file). In that
case, you also have the choice between forward declaration and
including the header file in the implementation file.



Thanks,
   Bernhard
