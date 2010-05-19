From: Kyle McMartin <kmcmartin@redhat.com>
Subject: Re: r8169 transmit queue time outs
Date: Wed, 19 May 2010 09:43:44 -0400
Message-ID: <20100519134344.GI3900@ihatethathostname.lab.bos.redhat.com>
References: <20100506141715.GC4480@ihatethathostname.lab.bos.redhat.com>
 <20100506201024.GA3541@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle McMartin <kmcmartin@redhat.com>, netdev@vger.kernel.org,
	dgilmore@redhat.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441Ab0ESNnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 09:43:50 -0400
Content-Disposition: inline
In-Reply-To: <20100506201024.GA3541@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 06, 2010 at 10:10:24PM +0200, Francois Romieu wrote:
> Kyle McMartin <kmcmartin@redhat.com> :
> [...]
> > Some of our users have been seeing their r8169 cards just up and stop
> > transmitting packets pretty quickly after boot with recent kernels.
> [...]
> > Pid: 0, comm: swapper Not tainted 2.6.31.5-127.fc12.i686.PAE #1
> 
> Can they upgrade to 2.6.32.11-99.fc12.i686 and try an out-of-tree build
> of the driver at http://userweb.kernel.org/~romieu/r8169/2.6.32.11-99.fc12/ ?
> 
> It should be quite close to the current git kernel.
> 

I provided a bunch of testers with a backport of the current git head
r8169 driver, and sadly, they report the TX timeout issues still occur.
:/

Any other ideas?

regards, Kyle
