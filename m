From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MD5: don't warn when an unexpected signature is seen.
Date: Wed, 30 Jul 2008 03:22:50 -0700 (PDT)
Message-ID: <20080730.032250.94870744.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069040@europa>
	<20080730.030830.229158162.davem@davemloft.net>
	<200807301216.01280.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: netdev@axxeo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37909
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752817AbYG3KWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 06:22:50 -0400
In-Reply-To: <200807301216.01280.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Oeser <netdev@axxeo.de>
Date: Wed, 30 Jul 2008 12:16:00 +0200

> > +	if (!hash_expected && hash_location) {
> > +		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_MD5UNEXPECTED);
> 
> This doesn't contain "_TCP" in the name. Why?

Because I didn't post the refreshed patch that I actually compile
tested :-)
