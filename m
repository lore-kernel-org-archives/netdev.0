From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 16:18:03 -0400
Message-ID: <20121019201803.GG8315@kvack.org>
References: <20121019194822.GF17417@1wt.eu> <20121019.154930.215119663249874810.davem@davemloft.net> <20121019195557.GG17417@1wt.eu> <20121019.160104.115897882147794932.davem@davemloft.net> <20121019200318.GH17417@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:44528 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932730Ab2JSUSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 16:18:05 -0400
Content-Disposition: inline
In-Reply-To: <20121019200318.GH17417@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 10:03:18PM +0200, Willy Tarreau wrote:
> OK. Is is because the issue is less important there or because the fix are
> more risky than the issues they fix (or any other reason) ?

The behaviour of 2.6.32.x is certainly a regression from previous stable 
kernels used by various distributions (ie 2.6.18), and is quite serious 
for those of us running routers on top of these releases.

		-ben
-- 
"Thought is the essence of where you are now."
