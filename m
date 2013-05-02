From: David Miller <davem@davemloft.net>
Subject: Re: RTA_SRC doesn't work?
Date: Thu, 02 May 2013 17:10:13 -0400 (EDT)
Message-ID: <20130502.171013.1977432139945346146.davem@davemloft.net>
References: <20130502.162101.1494997915474101391.davem@davemloft.net>
	<7iy5bxdsfg.wl%jch@pps.univ-paris-diderot.fr>
	<20130502.165459.532545271791758847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jch@pps.jussieu.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143Ab3EBVKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 17:10:15 -0400
In-Reply-To: <20130502.165459.532545271791758847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Actually, you're right, RTA_SRC is for source based routing.

But you can only do source based routing using FIB rules, the
normal routing tables (which are hung off of the rules) do not
have source keys in them.  They are keyed only by destination
address.

Only the FIB rules support source address keying.

So you will need to use multiple routing table to route by source
address.
