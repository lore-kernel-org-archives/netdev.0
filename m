From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH for 2.6.24] SCTP: Rewrite of sctp buffer management code
Date: Fri, 10 Aug 2007 20:35:29 -0400
Message-ID: <20070811003529.GA19807@hmsreliant.think-freely.org>
References: <46BCCE8B.2050605@hp.com> <20070810.150625.105430969.davem@davemloft.net> <20070810230126.GB3983@hmsreliant.homelinux.net> <20070810.163759.48396729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2936 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765136AbXHKAgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 20:36:48 -0400
Content-Disposition: inline
In-Reply-To: <20070810.163759.48396729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 04:37:59PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 10 Aug 2007 19:01:26 -0400
> 
> > Thanks for applying this Dave, but something seems to have occured during your
> > application.  The commitdiff:
> > http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.24.git;a=commitdiff;h=e20e5d698dcccd2e84ee2e1e482b0b203f885c00
> > only shows applications to socket.c, while the patch that vlad sent you changed
> > much more than that.
> 
> Vlad's posted patch only had the socket.c changes, that's the
> problem.  I just double checked in the archives on marc.info
> 
> I'm reverting this, please sort this out.

Vlad, this looks hosed in the same way in your lksctp-dev tree as well (Sorry I
didn't notice that sooner).  Can you dig the patch out of the lksctp archives?
Or shall I repost it to you?

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
