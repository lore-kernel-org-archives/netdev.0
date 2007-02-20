From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 20:18:10 +0300
Message-ID: <20070220171809.GA26961@2ka.mipt.ru>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru> <20070220170232.GA4730@outpost.ds9a.nl> <20070220171120.GD24930@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60228 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030321AbXBTRSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 12:18:18 -0500
Content-Disposition: inline
In-Reply-To: <20070220171120.GD24930@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 08:11:20PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> I would try it today - but it is a bit late in Moscow already - and
> there are some things to complete yet. So, tomorrow I will create a patch
> and run it, but I seriously doubt that there is _that_ high per-recvfrom 
> latency.

As of now - syscall which just copies 50 bytes from /dev/zero eats about
400-450 nanosecods per run (core duo 3.7 ghz).

-- 
	Evgeniy Polyakov
