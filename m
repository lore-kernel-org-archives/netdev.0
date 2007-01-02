From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ifb double-counts packets
Date: Mon, 01 Jan 2007 19:39:48 -0800 (PST)
Message-ID: <20070101.193948.36924222.davem@davemloft.net>
References: <Pine.LNX.4.64.0612230232410.29784@twinlark.arctic.org>
	<1166880592.3763.3.camel@localhost>
	<Pine.LNX.4.64.0612231355290.29784@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755245AbXABDjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jan 2007 22:39:49 -0500
To: dean@arctic.org
In-Reply-To: <Pine.LNX.4.64.0612231355290.29784@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dean gaudet <dean@arctic.org>
Date: Sat, 23 Dec 2006 13:58:24 -0800 (PST)

> On Sat, 23 Dec 2006, jamal wrote:
> 
> > On Sat, 2006-23-12 at 02:35 -0800, dean gaudet wrote:
> > > it seems that ifb counts packets twice... both at xmit time and also in 
> > > the tasklet.  i'm not sure which one of the two to drop, but here's a 
> > > patch for dropping the counting at xmit time.
> > 
> > Good catch but not quite right. The correct way to do it is to increment
> > the rx_ counters instead of tx_ right at the top of  ifb_xmit().
> > 
> > Do you wanna resubmit your patch with these chmages and hopefully tested
> > for your situation?
> 
> heh yeah that makes more sense :)
> 
> -dean
> 
> Signed-off-by: dean gaudet <dean@arctic.org>

Applied, thanks.
