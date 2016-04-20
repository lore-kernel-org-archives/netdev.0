From: Tony Lindgren <tony@atomide.com>
Subject: Re: Regression in next for smsc911x with tigthen lockdep checks
Date: Wed, 20 Apr 2016 08:32:30 -0700
Message-ID: <20160420153230.GI5995@atomide.com>
References: <20160420150108.GF5995@atomide.com>
 <57179EC9.6000505@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:51573 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbcDTPcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 11:32:35 -0400
Content-Disposition: inline
In-Reply-To: <57179EC9.6000505@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Hannes Frederic Sowa <hannes@stressinduktion.org> [160420 08:24]:
> Hi,
> 
> On 20.04.2016 17:01, Tony Lindgren wrote:
> > Looks like commit fafc4e1ea1a4 ("sock: tigthen lockdep checks for
> > sock_owned_by_user") in next causes a regression at least for
> > smsc911x with CONFIG_LOCKDEP. It keeps spamming with the following
> > message. Any ideas?
> 
> Not yet, can you quickly send me your config?

It's just the arch/arm/configs/omap2plus_defconfig I'm using.

Tony
