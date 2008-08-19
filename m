From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 22:29:17 -0700 (PDT)
Message-ID: <20080818.222917.10471071.davem@davemloft.net>
References: <20080818.013715.51438108.davem@davemloft.net>
	<48A9832D.7030402@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57901
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbYHSF3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 01:29:17 -0400
In-Reply-To: <48A9832D.7030402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 18 Aug 2008 16:11:57 +0200

> I think we really need either ->requeue or a real ->peek operation.

All the code duplication and complexity is what I'm trying to avoid.

I see no value in overhauling and auditing all of these ->requeue()
implementations and how they return status codes when the facility
itself is largely superfluous.

Maybe we can simply add a "bool peek" argument or some flags to
->dequeue() instead.
