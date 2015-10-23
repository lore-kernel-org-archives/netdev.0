From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute RFC PATCH 0/9] Document tc filters
Date: Sat, 24 Oct 2015 00:19:41 +0200
Message-ID: <20151023221941.GH22096@orbit.nwl.cc>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
 <20151023201302.GA2538@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51863 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbbJWWTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 18:19:43 -0400
Content-Disposition: inline
In-Reply-To: <20151023201302.GA2538@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 10:13:02PM +0200, Thomas Graf wrote:
> On 10/23/15 at 07:47pm, Phil Sutter wrote:
> >  man/man8/Makefile     |   4 +-
> >  man/man8/tc-basic.8   |  34 +++
> >  man/man8/tc-cgroup.8  |  80 ++++++
> >  man/man8/tc-flow.8    | 265 ++++++++++++++++++++
> >  man/man8/tc-flower.8  | 113 +++++++++
> >  man/man8/tc-fw.8      |  66 +++++
> >  man/man8/tc-route.8   |  74 ++++++
> >  man/man8/tc-tcindex.8 |  58 +++++
> >  man/man8/tc-u32.8     | 663 ++++++++++++++++++++++++++++++++++++++++++++++++++
> 
> This basically says everything regarding the usability of u32 ;-)

Quoting myself:

> Due to breaking everything down to values, masks and offsets, It is                            
> equally powerful and hard to use.

When I wrote that, I still had little idea of nexthdr+ and hash table
giblets. And even after digging through the code for quite some time,
I'm sure I don't.

> Joke aside, thanks so much for doing this work. This is wonderful.

Thanks a lot. I'm not entirely sure though the amount of correct
information prevails the factual errors. :)

Cheers, Phil
