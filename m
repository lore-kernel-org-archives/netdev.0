From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Extensible hashing and RCU
Date: 19 Feb 2007 13:04:12 +0100
Message-ID: <p73zm7ae4lf.fsf@bingen.suse.de>
References: <20070204074143.26312.qmail@science.horizon.com>
	<Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
	<20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com>
	<20070218191009.GA28216@2ka.mipt.ru> <45D8B54A.70903@cosmosbay.com>
	<f2b55d220702181323l5d2640a4g18df6d1ee051e987@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@linux.intel.com
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:45533 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932078AbXBSLEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 06:04:11 -0500
In-Reply-To: <f2b55d220702181323l5d2640a4g18df6d1ee051e987@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael K. Edwards" <medwards.linux@gmail.com> writes:

> A better data structure for RCU, even with a fixed key space, is
> probably a splay tree.  Much less vulnerable to cache eviction DDoS
> than a hash, because the hot connections get rotated up into non-leaf
> layers and get traversed enough to keep them in the LRU set.

LRU tends to be hell for caches in MP systems, because it writes to
the cache lines too and makes them exclusive and more expensive.

-Andi
