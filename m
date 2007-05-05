From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [-mm patch] fix fs/nfs/nfsroot.c compile error
Date: Sat, 05 May 2007 13:27:14 -0400
Message-ID: <1178386034.6561.53.camel@heimdal.trondhjem.org>
References: <20070505014955.8f3990b5.akpm@linux-foundation.org>
	 <20070505164422.GD8975@stusta.de>
	 <1178385646.6561.46.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	David Howells <dhowells@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:34920 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934086AbXEER1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2007 13:27:22 -0400
In-Reply-To: <1178385646.6561.46.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-05-05 at 13:20 -0400, Trond Myklebust wrote:
> On Sat, 2007-05-05 at 18:44 +0200, Adrian Bunk wrote:
> > On Sat, May 05, 2007 at 01:49:55AM -0700, Andrew Morton wrote:
> > >...
> > > Changes since 2.6.21-rc7-mm2:
> > >...
> > >  git-net.patch
> > >...
> > >  git trees
> > >...
> > 
> > match_table_t was made "const" and gcc doesn't like "const __initdata":
> 
> Then please revert the "fix" to match_table_t...
> 
> There is no reason for something like the nfsroot parser to be kept in
> memory after the system has booted. That would be code bloat.
> 
> Trond

Alternatively, please change the nfsroot parser to use

        static struct match_token tokens[] __initdata = {

That is in any case cleaner than using a typedef.

Trond

