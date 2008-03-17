From: David Miller <davem@davemloft.net>
Subject: Re: TCP timewait recycle/reuse for IPv6?
Date: Mon, 17 Mar 2008 12:11:10 -0700 (PDT)
Message-ID: <20080317.121110.182507644.davem@davemloft.net>
References: <47DEADC1.1040908@hp.com>
	<200803172004.33246.opurdila@ixiacom.com>
	<47DEB53F.9030108@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50643
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752577AbYCQTK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:10:59 -0400
In-Reply-To: <47DEB53F.9030108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 17 Mar 2008 11:15:27 -0700

> Octavian Purdila wrote:
> > While running the same traffic with IPv4, the timewait recyle/reuse
> > features kicks in and keeps the number of TIMEWAIT sockets to under a
> > 1000.
> 
> ISTR some discussion on the list about that recyling/reuse feature 
> perhaps going away.

The big problem is that it can't work in the presence of NAT
which basically makes it useless for the entire world.
