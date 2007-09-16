From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sun, 16 Sep 2007 17:43:45 +0400
Message-ID: <20070916134345.GA8059@2ka.mipt.ru>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070915122957.GA25752@2ka.mipt.ru> <20070915172446.GC2990@schatzie.adilger.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Andreas Dilger <adilger@clusterfs.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070915172446.GC2990@schatzie.adilger.int>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 15, 2007 at 11:24:46AM -0600, Andreas Dilger (adilger@clusterfs.com) wrote:
> > When Chris Mason announced btrfs, I found that quite a few new ideas 
> > are already implemented there, so I postponed project (although
> > direction of the developement of the btrfs seems to move to the zfs side
> > with some questionable imho points, so I think I can jump to the wagon
> > of new filesystems right now). 
> 
> This is an area I'm always a bit sad about in OSS development - the need
> everyone has to make a new {fs, editor, gui, etc} themselves instead of
> spending more time improving the work we already have.  Imagine where the

If that would be true, we would be still in the stone age. 
Or not, actually I think the first cell in the universe would not bother 
itself dividing into the two just because it could spent infinite time 
trying to make itself better.

> internet would be (or not) if there were 50 different network protocols
> instead of TCP/IP?  If you don't like some things about btrfs, maybe you
> can fix them?

When some idea is implemented it is virtually impossible to change it,
only recreate new one with fixed issues. So, we have multiple ext,
reiser and many others. I do not say btrfs is broken or has design
problems, it is really interesting filesystem, but all we have our own 
opinions about how things should be done, that's it.

Btw, we do have so many network protocols for different purposes, that
number of (storage) filesystems is negligebly small compared to it. 
Internet as is popular today is just a subset of where network is used.

And we do invent new protocols each time we need something new, which
does not fit into existing models (for example TCP by design can not
work with very long-distance links with tooo long RTT). We have sctp to
fix some tcp issues. Number of IP layer 'neighbours' is even more.
Physical media layer has many different protocols too.
And that is just what exists in the linux tree...

> To be honest, developing a new filesystem that is actually widely useful
> and used is a very time consuming task (see Reiserfs and Reiser4).  It
> takes many years before the code is reliable enough for people to trust it,
> so most likely any effort you put into this would be wasted unless you can
> come up with something that is dramatically better than something existing.

Yep, I know. 
Wasting my time is one of the most pleasant things I ever tried in my life.

> The part that bothers me is that this same effort could have been used to
> improve something that more people would use (btrfs in this case).  Of
> course, sometimes the new code is substantially better than what currently
> exists, and I think btrfs may have laid claim to the current generation of
> filesystems.

Call me greedy bastard, but I do not care about world happiness, it is
just impossible to achieve. So I like what I do right now.
If it will be rest under the layer of dust I do not care, I like the
process of creating, so if it will fail, I just will get new knowledge.

:)

> Cheers, Andreas
> --
> Andreas Dilger
> Principal Software Engineer
> Cluster File Systems, Inc.

-- 
	Evgeniy Polyakov
