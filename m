From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - in.h - IP4_ADDR
Date: Mon, 12 Nov 2007 21:39:37 -0800
Message-ID: <1194932377.9407.68.camel@localhost>
References: <1194837570.9407.29.camel@localhost>
	 <20071112.212814.130544552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3940 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbXKMFji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 00:39:38 -0500
In-Reply-To: <20071112.212814.130544552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-12 at 21:28 -0800, David Miller wrote:
> I have no problems with this, but I'd like to add it along
> with subsequent patches that use the new routines and
> also I'd like to defer this to net-2.6.25 so please resubmit
> this later.

I've since changed the functions in my tree to:

	static inline bool is_ip4_foo(__be32 addr)

and added

	# define FOO(x) is_ip4_foo(x)

which I think makes more sense and allows macro
removal when all current uses are converted.

When you open net-2.6.25, I'll resubmit it.

