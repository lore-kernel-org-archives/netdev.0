From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [0/7] Distributed storage release.
Date: Sun, 28 Dec 2008 16:37:11 +0300
Message-ID: <20081228133711.GA858@ioremap.net>
References: <1230292576-23963-1-git-send-email-zbr@ioremap.net> <20081226191701.GA1761@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, dst@ioremap.net,
	netdev@vger.kernel.org
To: Pavel Machek <pavel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:57910 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517AbYL1NhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Dec 2008 08:37:14 -0500
Content-Disposition: inline
In-Reply-To: <20081226191701.GA1761@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 26, 2008 at 08:17:02PM +0100, Pavel Machek (pavel@suse.cz) wrote:
> > Its main goal of the project is to allow creation of the block devices
> > on top of different network media and connect physically distributed devices
> > into single storage using existing network infrastructure and not
> > introducing new limitations into the protocol and network usage model.
> 
> So it is basically nbd on steroids?

Kind of... In this regard any network device which transfers IO and
related requests over the network is a nbd on steroids.

> ...reminds me, nbd-server should really fsync data before returning success...

There are lots of issues NBD could have at first... When I compared DST
with AoE and NFS, Debian Lenny/Etch's nbd server crashed on startup, so
I was not able to run my tests against it.

-- 
	Evgeniy Polyakov
