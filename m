From: David Miller <davem@davemloft.net>
Subject: Re: net-sched 01/02: change tcf_destroy_chain() to clear start of
 filter list
Date: Tue, 01 Jul 2008 19:53:21 -0700 (PDT)
Message-ID: <20080701.195321.77571420.davem@davemloft.net>
References: <486A019E.7000200@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60389
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752115AbYGBCxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 22:53:21 -0400
In-Reply-To: <486A019E.7000200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 01 Jul 2008 12:06:22 +0200

> These two patches fix a potential use-after-free in hfsc
> and atm filter destruction. All filters must be destroyed
> before beginning class destruction since the destination
> class must still be alive to unbind the filter.

Both patches applied to net-2.6, thanks!
