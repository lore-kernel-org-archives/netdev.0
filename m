From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Wed, 29 Oct 2008 11:22:15 -0700 (PDT)
Message-ID: <20081029.112215.33710480.davem@davemloft.net>
References: <20081029102356.GA6165@ff.dom.local>
	<49083BF5.5090606@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752576AbYJ2SWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:22:40 -0400
In-Reply-To: <49083BF5.5090606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 29 Oct 2008 11:33:25 +0100

> Jarek Poplawski wrote:
> > On the other hand, it seems with shaping qdiscs they are more useful
> > to query dequeue rates.
> 
> Only for purely informational purposes, for policing you'd want to
> use arrival rates. Since there are no users of estimators in the kernel
> besides policers (which use seperate ones), the point is not terribly
> important. But I would prefer to not start introducing (or extending)
> inconsistencies among qdisc implementations here, that will only make
> it harder in case someone finally implements something useful with
> estimators.

I agree with Patrick %100
