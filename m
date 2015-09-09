From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: netdev: add a cast NLMSG_OK to avoid a GCC warning in
 users' code
Date: Wed, 09 Sep 2015 12:37:17 -0700 (PDT)
Message-ID: <20150909.123717.2263645868892698375.davem@davemloft.net>
References: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hugh@mimosa.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbIIThS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:37:18 -0400
In-Reply-To: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "D. Hugh Redelmeier" <hugh@mimosa.com>
Date: Tue, 8 Sep 2015 09:46:56 -0400 (EDT)

> Using netlink.h's NLMSG_OK correctly will cause GCC to issue a warning
> on systems with 32-bit userland.  The definition can easily be changed
> to avoid this.

Everyone either uses an unsigned type (such as "size_t") or adds an
explicit cast to an unsinged type for the second argument.

The code you were trying to compile should do so as well.

I'm not applying this, sorry.
