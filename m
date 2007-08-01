From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: ATA over ethernet swapping
Date: Wed, 01 Aug 2007 11:18:29 +0200
Message-ID: <1185959909.12034.38.camel@twins>
References: <20070731135831.GA4604@elf.ucw.cz>
	 <20070731150324.GE3206@coraid.com> <20070731152924.GM2087@elf.ucw.cz>
	 <20070731162140.GI3206@coraid.com>  <20070731222742.GR2087@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ed L. Cashin" <ecashin@coraid.com>,
	kernel list <linux-kernel@vger.kernel.org>, ak@suse.de,
	Netdev list <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60916 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbXHAJSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 05:18:33 -0400
In-Reply-To: <20070731222742.GR2087@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been working on this for quite some time. And should post again
soon. Please see the patches:

  http://programming.kicks-ass.net/kernel-patches/vm_deadlock/current/

For now it requires one uses SLUB, I hope that SLAB will go away (will
save me the trouble of adding support) and I guess I ought to do SLOB
some time (if that does stay).

You'd need the first 22 patches of that series, and then call
sk_set_memalloc(sk) on the proper socket, and do some fiddling with the
reconnect logic. See nfs-swapfile.patch for examples.


