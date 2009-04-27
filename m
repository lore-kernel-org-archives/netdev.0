From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Sun, 26 Apr 2009 23:35:08 -0700 (PDT)
Message-ID: <20090426.233508.192017779.davem@davemloft.net>
References: <20090427030433.GA17454@kryten>
	<49F53FF6.2040603@cosmosbay.com>
	<20090427054702.GA15891@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751748AbZD0GfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 02:35:14 -0400
In-Reply-To: <20090427054702.GA15891@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Mon, 27 Apr 2009 15:47:02 +1000

>> Sorry this limit is too small. Many of my customer machines would collapse.
> 
> So what would a reasonable upper limit be? Surely we should cap it at some
> point?

32MB is even small for some people.

Like Eric, I think the current cap is just fine.  For special
situations, tweak settings :)
