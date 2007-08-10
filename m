From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH for 2.6.24] SCTP: Rewrite of sctp buffer management code
Date: Fri, 10 Aug 2007 19:01:26 -0400
Message-ID: <20070810230126.GB3983@hmsreliant.homelinux.net>
References: <46BCCE8B.2050605@hp.com> <20070810.150625.105430969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3369 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbXHJXCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 19:02:24 -0400
Content-Disposition: inline
In-Reply-To: <20070810.150625.105430969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 03:06:25PM -0700, David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 10 Aug 2007 16:46:03 -0400
> 
> > This patch introduces autotuning to the sctp buffer management code
> > similar to the TCP.  The buffer space can be grown if the advertised
> > receive window still has room.  This might happen if small message
> > sizes are used, which is common in telecom environmens.
> > New tunables are introduced that provide limits to buffer growth
> > and memory pressure is entered if to much buffer spaces is used.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> Applied, thanks Vlad.
> 
> Can you in the future fix up whitespace issues like this:
> 
> Adds trailing whitespace.
> diff:21: 
> Space in indent is followed by a tab.
> diff:27: 	int amt;
> Space in indent is followed by a tab.
> diff:48: 		amt = asoc->base.sk->sk_sndbuf - amt;
> Space in indent is followed by a tab.
> diff:55:  	return amt;
> 
> I know where the "Space in indent" cases come from, you apply the
> patch to merge it into a current tree, you get rejects, then you edit
> in the foo.rej hunks by hand into the code but forget to remove the
> extra leading whitespace characters.
> 
> :-)

Thanks for applying this Dave, but something seems to have occured during your
application.  The commitdiff:
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.24.git;a=commitdiff;h=e20e5d698dcccd2e84ee2e1e482b0b203f885c00
only shows applications to socket.c, while the patch that vlad sent you changed
much more than that.  Not sure If I'm seeing something thats transient, but I
wanted to bring it to your attention in the event that something has in fact
gone awry.  

Thanks & Regards to you both
Neil

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
