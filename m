From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] (02/14/08 Linus git) Smack unlabeled outgoing ambient packets - v3
Date: Fri, 15 Feb 2008 16:08:22 -0500
Message-ID: <200802151608.22479.paul.moore@hp.com>
References: <291070.74513.qm@web36606.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:35432 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756457AbYBOVI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 16:08:27 -0500
In-Reply-To: <291070.74513.qm@web36606.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 15 February 2008 4:00:26 pm Casey Schaufler wrote:
> --- Paul Moore <paul.moore@hp.com> wrote:
> > On Friday 15 February 2008 12:38:49 am Casey Schaufler wrote:
> > ... you shouldn't fix-up the return value from
> > netlbl_sock_setattr(). It only returns an error when there really
> > is an error, if there are no matching domain mappings and the
> > default catches the "domain" then the function will return 0
> > (assuming no other failures).
> >
> > The fact that you ran into this problem isn't your fault, it's
> > mine, but thankfully for both of us Pavel Emelyanov found this bug
> > and fixed it[1].  It hasn't hit Linus' tree yet but it's in the
> > net-2.6 tree.  If you can't wait for it to hit Linus' tree you can
> > always apply the fix by hand, it's pretty minor.
> >
> > Sorry about that.
>
> [1]http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=comm
>it;h=4c3a0a254e5d706d3fe01bf42261534858d05586
>
> Yerk. I can put that fix into my tree, but my patch without
> the "correction" makes sockets behave very badly. I can't have
> people using it without Pavel's fix. Any notion on the plans to
> get that in?

It is already "in", it just hasn't percolated up to Linus' tree yet.  In 
the past I've always dealt with similar issues by just waiting until 
the patch I need has hit Linus' tree then submitted my patch.  If you 
can't wait, you can always rebase your patch against the net-2.6 tree 
(should be no work at all) and if DaveM doesn't have a problem pulling 
your patch into the net-2.6 tree you can always send it up that way.

-- 
paul moore
linux security @ hp
