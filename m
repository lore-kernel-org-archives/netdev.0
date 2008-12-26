From: Pavel Machek <pavel@suse.cz>
Subject: Re: [0/7] Distributed storage release.
Date: Fri, 26 Dec 2008 20:17:02 +0100
Message-ID: <20081226191701.GA1761@ucw.cz>
References: <1230292576-23963-1-git-send-email-zbr@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, dst@ioremap.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:36711 "EHLO
	gprs189-60.eurotel.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbYL1Hn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2008 02:43:57 -0500
Content-Disposition: inline
In-Reply-To: <1230292576-23963-1-git-send-email-zbr@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri 2008-12-26 14:56:09, Evgeniy Polyakov wrote:
> Hi.
> 
> This is a maintenance distributed storage release, which includes a
> rebase against the 2.6.28 kernel tree only.
> 
> DST is a network block device storage, which can be used to organize
> exported storages on the remote nodes into the local block device.
> 
> Its main goal of the project is to allow creation of the block devices
> on top of different network media and connect physically distributed devices
> into single storage using existing network infrastructure and not
> introducing new limitations into the protocol and network usage model.

So it is basically nbd on steroids?

...reminds me, nbd-server should really fsync data before returning success...
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
