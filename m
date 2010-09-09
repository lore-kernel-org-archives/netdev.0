From: Kyle McMartin <kmcmartin@redhat.com>
Subject: Re: r8169 transmit queue time outs
Date: Thu, 9 Sep 2010 13:32:34 -0400
Message-ID: <20100909173234.GB19458@ihatethathostname.lab.bos.redhat.com>
References: <20100506141715.GC4480@ihatethathostname.lab.bos.redhat.com>
 <20100506201024.GA3541@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle McMartin <kmcmartin@redhat.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43497 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753281Ab0IIRcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Sep 2010 13:32:47 -0400
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

Just fyi, we finally figured out what this problem was, or at least, a
workaround for it. Turning off PCI Express ASPM seemed to work around
the problem.

regards, Kyle
