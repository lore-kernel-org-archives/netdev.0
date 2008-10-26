From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config
 option
Date: Sun, 26 Oct 2008 13:16:44 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0810261315040.3386@nehalem.linux-foundation.org>
References: <20081026103024.2712ddc9@infradead.org> <20081026200939.GC12648@tuxdriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com,
	johannes@sipsolutions.net
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35095 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754899AbYJZUSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 16:18:17 -0400
In-Reply-To: <20081026200939.GC12648@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 26 Oct 2008, John W. Linville wrote:
> 
> Is it common practice to have compatibility options default to
> "y"?  I'm not saying it shouldn't be, just wondering if it has been
> traditionally?

Yes. Generally the rule should be that

	make oldconfig

with 'default values for all new options' should give you a configuration 
that is essentially identical to the old one.

So if it's a config option to enable compatibility with old kernels, it 
should default to 'y'. If it's a new driver or a new feature that didn't 
exist in previous kernels, it should default to 'n'.

			Linus
