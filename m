From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 16:05:13 -0700
Message-ID: <20080414160513.9f57e5ba.akpm@linux-foundation.org>
References: <20080413232441.e216a02c.akpm@linux-foundation.org>
	<20080414072328.GW9785@ZenIV.linux.org.uk>
	<Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
	<20080414.150105.101568769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, viro@ZenIV.linux.org.uk, w@1wt.eu,
	david@lang.hm, sclark46@earthlink.net, johnpol@2ka.mipt.ru,
	rjw@sisk.pl, tilman@imap.cc, Valdis.Kletnieks@vt.edu, lkml@rtr.ca,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, git@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <git-owner@vger.kernel.org>
In-Reply-To: <20080414.150105.101568769.davem@davemloft.net>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Apr 2008 15:01:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: James Morris <jmorris@namei.org>
> Date: Tue, 15 Apr 2008 01:54:00 +1000 (EST)
> 
> > - Things like "who made the kernel" statistics and related articles ignore 
> >   code review.
> 
> Note the apparent irony in that the person who ends up often on the
> top of those lists, Al Viro, is also someone who also does a
> significant amount of code review.
> 
> I think this is no accident.

"who made the kernel" was an interesting and useful exercise, but if you
like irony then...

- The way to boost your commit count is to submit buggy patches and to
  then fix your own bugs.

- The way to lower your commit count is to fix things in other people's
  patches, then fold your fix into the base patch.  I've lost over 1000
  commits that way.  Unless they are counting '^    [akpm' as a commit.
