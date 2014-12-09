From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: the next chunk of iov_iter-net stuff for review
Date: Tue, 9 Dec 2014 21:04:14 +0000
Message-ID: <20141209210414.GJ22149@ZenIV.linux.org.uk>
References: <20141125205911.GA29748@ZenIV.linux.org.uk>
 <20141126.122727.1791815907895724977.davem@davemloft.net>
 <20141205055623.GQ29748@ZenIV.linux.org.uk>
 <20141209.150732.158834258918114526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141209.150732.158834258918114526.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 09, 2014 at 03:07:32PM -0500, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Fri, 5 Dec 2014 05:56:23 +0000
> 
> > 	OK, here's the tentative next batch (covers most of the ->recvmsg()
> > side of conversion).  That's on top of merge of net-next#master with
> > vfs#iov_iter (the latter had been posted earlier today, Cc'd to netdev among
> > other places).  This series corresponds to vfs#for-davem.  Review and comments
> > would be very welcome...
> 
> Al, what's the state of this?  The iov_iter rewrite had some changes
> recently.

Well, I've got no comments whatsoever on the networking side of things;
might mean that everything's fine, might mean that everyone had been too
polite to say it's shite, might be something in between...  FWIW, changes
in iov_iter do not affect any of those patches, so the stuff posted
for review is unchanged by those.

> Also, never assume I just know what GIT url to pull from, always
> explicitly state where you want me to pull changes from.

Sure, but that was just a call for review.  _If_ you think that those patches
are OK, the URL is
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem
(and it pulls the fixed variant of iov_iter, otherwise it's exactly the same
as when I posted those).

FWIW, this stuff seems to work here, but I'd really like to hear at least
something before asking to pull.  As it is, your mail is the first reply of
any kind...
