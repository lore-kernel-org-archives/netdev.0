From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: don't annotate MAC registers as packed
Date: Wed, 25 May 2011 17:57:28 -0400 (EDT)
Message-ID: <20110525.175728.1531164565330440303.davem@davemloft.net>
References: <1306321642-2861-1-git-send-email-uli@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uli@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab1EYV5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:57:33 -0400
In-Reply-To: <1306321642-2861-1-git-send-email-uli@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Hecht <uli@suse.de>
Date: Wed, 25 May 2011 13:07:22 +0200

> On ARM, memory accesses through packed pointers behave in unexpected
> ways in GCC releases 4.3 and higher; see https://lkml.org/lkml/2011/2/2/163
> for discussion.
> 
> In this particular case, 32-bit I/O registers are accessed bytewise,
> causing incorrect setting of the DMA address registers which in turn
> leads to an error interrupt storm that brings the system to a halt.
> 
> Since the mac_regs structure does not need any packing anyway, this patch
> simply removes the attribute to fix the issue.
> 
> Signed-off-by: Ulrich Hecht <uli@suse.de>

Applied.
