From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 4 Aug 2003 09:10:53 +0300 (EEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0308040908070.11876-100000@netcore.fi>
References: <20030728213933.F81299@coredump.scriptkiddie.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bill Davidsen <davidsen@tmr.com>,
	"David S. Miller" <davem@redhat.com>,
	Carlos Velasco <carlosev@newipnet.com>, <bloemsaa@xs4all.nl>,
	<marcelo@conectiva.com.br>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>, <layes@loran.com>,
	<torvalds@osdl.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Lamont Granquist <lamont@scriptkiddie.org>
In-Reply-To: <20030728213933.F81299@coredump.scriptkiddie.org>
List-Id: netdev.vger.kernel.org

Hi,

Just a thought..

How about consider this change for 2.6 kernel series at this point, and 
don't backport it 2.4 at least first and/or make the behaviour 
configurable?

Upgrading from 2.4 to 2.6 should be a step big enough that folks should 
revisit their more advanced configurations, causing smaller surprises.  
Changing the behaviour inside 2.4.x series might not be reasonable.

On Mon, 28 Jul 2003, Lamont Granquist wrote:
> On Mon, 28 Jul 2003, Bill Davidsen wrote:
> > On Sun, 27 Jul 2003, David S. Miller wrote:
> > > This particular case has been discussed to death in the past
> > > and I really recommend people read up there before dragging this
> > > out further.
> >
> > It will keep coming back because it's a real problem. I do agree that the
> > hidden patch is not the desired way to solve the problem, but until there
> > is a reasonable (not requiring a guru or large manual effort) solution
> > people will keep bringing it up.
> 
> And it severely violates the principle of least surprise.  Its unfortunate
> that this principle isn't more widely discussed and considered on lkml.
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

