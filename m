From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config
	option
Date: Sun, 26 Oct 2008 16:44:41 -0400
Message-ID: <20081026204441.GA29566@tuxdriver.com>
References: <20081026103024.2712ddc9@infradead.org> <20081026200939.GC12648@tuxdriver.com> <20081026131818.7517c103@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com,
	johannes@sipsolutions.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55777 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbYJZUp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 16:45:29 -0400
Content-Disposition: inline
In-Reply-To: <20081026131818.7517c103@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 26, 2008 at 01:18:18PM -0700, Arjan van de Ven wrote:
> On Sun, 26 Oct 2008 16:09:39 -0400
> "John W. Linville" <linville@tuxdriver.com> wrote:
> f
> > > Change the default to "y" and also adjust the config text a little
> > > to reflect this.
> > 
> > Is it common practice to have compatibility options default to
> > "y"?  I'm not saying it shouldn't be, just wondering if it has been
> > traditionally?
> 
> yes
> 
> default should be "keep working as before"
> 
> it's not always nice, especially if you're trying to get rid of some
> nasty stuff, but think of it this way: you should be able to use a
> new kernel on an existing distro, at least for a reasonable type of
> distro (eg something shipped in, say, the last 2 years). In this case:
> even Fedora 10 is not likely to work!

Well, I intended to make sure the Fedora guys picked the right option. :-)

Anyway, I'm fine with default 'y'...however, Luis is probably somewhere
buying a gun and looking-up your home address...just kidding...mostly... :-)

John
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
