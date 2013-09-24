From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 14:48:30 -0400 (EDT)
Message-ID: <20130924.144830.994116727011585720.davem@redhat.com>
References: <CA+mtBx_tWS44q8jER+QtR5k4k2ieq99He6YdPF8KKBF4Z2+32w@mail.gmail.com>
	<1380044075.3165.108.camel@edumazet-glaptop>
	<CA+mtBx8PJj1HgaoiOoJjQL6VmU4Rn7ctBpscr1YxpfrWW9VSbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab3IXSsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 14:48:38 -0400
In-Reply-To: <CA+mtBx8PJj1HgaoiOoJjQL6VmU4Rn7ctBpscr1YxpfrWW9VSbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 24 Sep 2013 11:02:11 -0700

> But if we already have valid l4_rxhash we're just wasting time
> recomputing it (very like the same value).  So just do:

Honestly, you're arguing over 12 or so cycles.  That's about how much
jhash costs.
