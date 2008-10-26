From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config
 option
Date: Sun, 26 Oct 2008 13:18:18 -0700
Message-ID: <20081026131818.7517c103@infradead.org>
References: <20081026103024.2712ddc9@infradead.org>
	<20081026200939.GC12648@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com,
	johannes@sipsolutions.net
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41685 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbYJZUSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 16:18:07 -0400
In-Reply-To: <20081026200939.GC12648@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Oct 2008 16:09:39 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:
f
> > Change the default to "y" and also adjust the config text a little
> > to reflect this.
> 
> Is it common practice to have compatibility options default to
> "y"?  I'm not saying it shouldn't be, just wondering if it has been
> traditionally?

yes

default should be "keep working as before"

it's not always nice, especially if you're trying to get rid of some
nasty stuff, but think of it this way: you should be able to use a
new kernel on an existing distro, at least for a reasonable type of
distro (eg something shipped in, say, the last 2 years). In this case:
even Fedora 10 is not likely to work!



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
