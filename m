From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 03/18] drivers/net/ns83820.c: add paramter to disable autonegotiation
Date: Fri, 10 Aug 2007 17:13:49 -0400
Message-ID: <20070810211349.GD978@kvack.org>
References: <200708102105.l7AL5ERH008951@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, dan@scannet.dk,
	dan@hacker.dk, jgarzik@pobox.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:38123 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753597AbXHJVOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 17:14:35 -0400
Content-Disposition: inline
In-Reply-To: <200708102105.l7AL5ERH008951@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 02:05:13PM -0700, akpm@linux-foundation.org wrote:
> Also added a "disable_autoneg" module argument to completely disable
> autoneg on all cards using this driver.
...
> [akpm: this is a previously-nacked patch, but the problem is real]

Please remove this part of the patch.  The ethtool support is sufficient and 
doesn't clobber other cards in the system.  At the very least the module 
parameter has to be limited to a specific card.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
