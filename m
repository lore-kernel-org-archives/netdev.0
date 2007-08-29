From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:37:24 -0700 (PDT)
Message-ID: <20070829.153724.115627471.davem@davemloft.net>
References: <46D5EEB6.3020602@hp.com>
	<20070829.152059.48818008.davem@davemloft.net>
	<5640c7e00708291533s30868cc8t69b989f0e53b9569@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: ian.mcdonald@jandi.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754866AbXH2Whe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:37:34 -0400
In-Reply-To: <5640c7e00708291533s30868cc8t69b989f0e53b9569@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Aug 2007 10:33:32 +1200

> Correct - they often have flaws in them, just like all documents. If
> that is the case we should try and get the RFCs fixed.

In many cases it is not the wording, but the actual concept or idea
the RFC itself is describing which is fatally flawed.

TCP timestamps are a great example, as designed they simply do not
work when ACKs are reordered by the network because it makes the PAWS
test fail for the out of order ACKs.

Therefore everyone adds an extra fuzz to the PAWS test so that a small
window of "older" packets are allowed to pass the check.
