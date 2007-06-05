From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: warnings in git-wireless
Date: Tue, 5 Jun 2007 16:26:33 -0700
Message-ID: <20070605162633.8aed0a21.akpm@linux-foundation.org>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org>
	<20070605115701.GA5391@tuxdriver.com>
	<4665C393.2000507@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37090 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762844AbXFEX1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 19:27:16 -0400
In-Reply-To: <4665C393.2000507@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 05 Jun 2007 13:12:03 -0700
James Ketrenos <jketreno@linux.intel.com> wrote:

> John W. Linville wrote:
> > On Tue, Jun 05, 2007 at 02:06:14AM -0700, Andrew Morton wrote:
> > 
> >> Please, don't anybody dare think about thinking about letting this anywhere
> >> near mainline until it has had a thorough review.  Or at least, a little bit
> >> of review.
> > 
> > Don't worry -- I assure you that everyone is aware of the issues.
> > 
> > John
> 
> Yes, we certainly don't want a driver to be "near mainline" that does things that the rest of the kernel and other drivers are doing.  We should force them to stay out-of-tree until any and everything is resolved.  Heaven forbid that the code should be merged, contributed, and improved upon as a community.

That isn't the only decision criterion.

Overall the c files look reasonable to me: a few little things like large
on-stack arrays built at runtim which I think could be assembled at
compile-time, various unneeded casts, a bit of space-vs-tab confusion, but
nothing serious leaps out.

So perhaps that header file was unrepresentative.  It is seriously
duplicative and bloaty though.



This:

akpm:/usr/src/25> perl scripts/checkpatch.pl patches/git-wireless.patch | wc -l
9941

should be an endless source of fun.

