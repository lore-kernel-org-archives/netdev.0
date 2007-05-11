From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 08:56:04 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902D42246@orsmsx414.amr.corp.intel.com>
References: <1178842400.5008.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>, "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24594 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758133AbXEKP4I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 11:56:08 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178842400.5008.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This compiles and passes some basic tests - no serious testing.
> Against net-2.6.
> 
> The patch is ugly looking, so i have at the end the 
> re-written qdisc; you can easily tell the rest from the patch.
> 
> Please flush out any fluff - I would like to submit this 
> (almost lost it, thanks to an early posting, found it).
> 
> 
> cheers,
> jamal

In qdisc_restart(), you removed any check for if
(!netif_queue_stopped(dev)) before calling dev_hard_start_xmit().  If
the underlying queue is stopped and you send the skb, you'll generate a
requeue.  Is there a reason it was removed?

Thx,

-PJ Waskiewicz 
