From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next
 tree
Date: Thu, 17 Mar 2016 07:52:46 +1100
Message-ID: <20160317075246.39a08e61@canb.auug.org.au>
References: <20160316115809.61b4478e@canb.auug.org.au>
	<CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Amir Vadai <amir@vadai.me>, Maor Gottlieb <maorg@mellanox.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:47072 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756133AbcCPUwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 16:52:49 -0400
In-Reply-To: <CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Wed, 16 Mar 2016 10:18:33 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> On Tue, Mar 15, 2016 at 5:58 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > I fixed it up (see below) and can carry the fix as necessary (no action
> > is required).  
> 
> Side note: can you change this wording for your manual merge script?
> Last merge window (or was it the one before it?) we had confusion with
> people who thought that "no action is required" means "you can just
> ignore this entirely".
> 
> I want people who have known merge issues to at the very least
> *mention* them to me when they send the pull request, and I also think
> that trees that have merge conflicts that aren't just totally trivial
> should also make sure that they have communicated with each other
> about why the problem happened.
> 
> This is *particularly* true for the complete effing disaster that is
> mellanox and rdma-vs-networking.
> 
> So please don't say "no action is required". Please make it clear that
> there may not be any further action needed for linux-next itself, but
> that other action may certainly be required.

Yeah, I can see your point.  The "no action required" was a reaction to
people going off and rebasing their tree or dropping patches at any
sign of a conflict at all.

How about "This is now fixed as far as linux-next is concerned, but any
non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may want also want to
consider cooperate with the maintainer of the conflicting tree to
minimise any particularly complex conflicts."

-- 
Cheers,
Stephen Rothwell
