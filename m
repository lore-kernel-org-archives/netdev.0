From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] qdisc_run de inline.
Date: Thu, 31 May 2007 01:29:30 -0700 (PDT)
Message-ID: <20070531.012930.85414722.davem@davemloft.net>
References: <20070530092324.2f0fa703@freepuppy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753571AbXEaI3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 04:29:16 -0400
In-Reply-To: <20070530092324.2f0fa703@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 30 May 2007 09:23:24 -0700

> It isn't worth inlining qdisc_run, into two parts. The code is
> cleaner (and smaller) to just have it as one routine.

This looks fine to me, I'll queue it up for 2.6.23 once I
cut the net-2.6.23 tree.

Thanks.
