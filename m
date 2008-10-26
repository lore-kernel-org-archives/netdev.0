From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config
	option
Date: Sun, 26 Oct 2008 16:09:39 -0400
Message-ID: <20081026200939.GC12648@tuxdriver.com>
References: <20081026103024.2712ddc9@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com,
	johannes@sipsolutions.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38654 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbYJZUKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 16:10:41 -0400
Content-Disposition: inline
In-Reply-To: <20081026103024.2712ddc9@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 26, 2008 at 10:30:24AM -0700, Arjan van de Ven wrote:
> From 9095a0f6005a8f50c79e51f4aaceda95e361a891 Mon Sep 17 00:00:00 2001
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Sun, 26 Oct 2008 10:25:30 -0700
> Subject: [PATCH] wireless: fix regression caused by regulatory config option
> 
> The default for the regulatory compatibility option is wrong;
> if you picked the default you ended up with a non-functional wifi
> system (at least I did on Fedora 9 with iwl4965).
> I don't think even the October 2008 releases of the various distros
> has the new userland so clearly the default is wrong, and also
> we can't just go about deleting this in 2.6.29...
> 
> Change the default to "y" and also adjust the config text a little to
> reflect this.

Is it common practice to have compatibility options default to
"y"?  I'm not saying it shouldn't be, just wondering if it has been
traditionally?

John
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
