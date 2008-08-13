From: David Miller <davem@davemloft.net>
Subject: Re: Question on how to select specific tx queues for tx multiqueue
 in 2.6.27
Date: Wed, 13 Aug 2008 15:14:06 -0700 (PDT)
Message-ID: <20080813.151406.78768732.davem@davemloft.net>
References: <80769D7B14936844A23C0C43D9FBCF0F13E0F8FF@orsmsx501.amr.corp.intel.com>
	<20080813.151102.203389904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48634
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752133AbYHMWOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 18:14:05 -0400
In-Reply-To: <20080813.151102.203389904.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 13 Aug 2008 15:11:02 -0700 (PDT)

> You can write a qdisc that does these things if you wish.

Actually it could be as simple as a new TC action that sets
the queue selected, or perhaps an EMATCH.

