From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Extensible hashing and RCU
Date: 19 Feb 2007 23:10:09 +0100
Message-ID: <p73mz39er3y.fsf@bingen.suse.de>
References: <20070204074143.26312.qmail@science.horizon.com>
	<45D8B54A.70903@cosmosbay.com> <20070219114117.GA22622@2ka.mipt.ru>
	<200702191438.14010.dada1@cosmosbay.com>
	<20070219135608.GA10268@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35845 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932688AbXBSVKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 16:10:24 -0500
In-Reply-To: <20070219135608.GA10268@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> 
> My experiment shows almost 400 nsecs without _any_ locks - they are
> removed completely - it is pure hash selection/list traverse time.

Are you sure you're not measuring TLB misses too? In user space
you likely use 4K pages. The kernel would use 2MB pages.
I would suggest putting the tables into hugetlbfs allocated memory
in your test program.

-Andei
