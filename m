From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] be2net: Clear pending tx completions
 before destroying tx queue
Date: Wed, 12 Aug 2009 22:16:36 -0700 (PDT)
Message-ID: <20090812.221636.209483501.davem@davemloft.net>
References: <20090810134243.GA10640@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751895AbZHMFQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:16:26 -0400
In-Reply-To: <20090810134243.GA10640@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 10 Aug 2009 19:12:43 +0530

> Clear pending tx completions in be_close() (ndo.stop method) so that after
> unregister_netdev() calls be_close(), all tx skbs are freed and there are
> no more tx completions when txq is destroyed.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
