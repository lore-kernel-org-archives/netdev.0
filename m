From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibm emac: delete module references; phy.c
 only supported as built-in
Date: Mon, 27 Feb 2012 14:57:53 -0500 (EST)
Message-ID: <20120227.145753.1111293673513137413.davem@davemloft.net>
References: <1330372024-30974-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org,
	linuxppc-dev@lists.ozlabs.org, jwboyer@gmail.com,
	mporter@kernel.crashing.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937Ab2B0UAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 15:00:41 -0500
In-Reply-To: <1330372024-30974-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 27 Feb 2012 14:47:04 -0500

> The Makefile has it as "ibm_emac-y := mal.o core.o phy.o" so there is
> no way this can be built modular, so remove all references to module
> support.

That doesn't mean it's only buildable statically.

"ibm_emacs-y :=" is merely a way to tell make what objects go into ibm_emac.{o,ko}

IBM_EMAC is tristate
