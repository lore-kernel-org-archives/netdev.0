From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_u32 u32_classify()
Date: Mon, 18 Feb 2008 21:46:00 -0800 (PST)
Message-ID: <20080218.214600.94322068.davem@davemloft.net>
References: <47A078AE.6060500@bspu.unibel.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by, mahatma@bspu.unibel.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755145AbYBSFpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 00:45:23 -0500
In-Reply-To: <47A078AE.6060500@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Date: Wed, 30 Jan 2008 11:16:30 -0200

> Currently fine u32 "hashkey ... at ..." not work with relative offsets.
> There are simpliest fix to use "eat".

So the question is whether 'sel' is defined to be calculated
before all offsets and EAT operations are processed or before.

I do not understand the U32 classifier enough to know what
this kind of change might or might not break.

Can some u32 expert review this?

Thanks.
