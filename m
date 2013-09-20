From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 3/4] net: VSI: Add virtual station interface support
Date: Fri, 20 Sep 2013 19:12:59 -0400
Message-ID: <20130920231259.GA31479@neilslaptop.think-freely.org>
References: <20130911184718.26914.98366.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48906 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab3ITXN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 19:13:27 -0400
Content-Disposition: inline
In-Reply-To: <20130911184718.26914.98366.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


John-
     Sorry for not copying your orgional patch into your email, but I apparently
erased this email prior to fully reading it.  At any rate, as we discussed the
other day, I think this idea is great, but it would benefit from being
implemented using macvlans rather than a new link type.  If we can set a
hardware flag in the underlying driver to indicate support for hardware
forwarding, we can skip the macvlan soft forwarding, and just transmit directly.
It should save us needing to create a whole new link type that is so simmilar to
one we already have.

     I'm back home now, so I can start looking at this if you like on monday.

Best
Neil
