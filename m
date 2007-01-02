From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm_user: avoid pointless void ** casts
Date: Tue, 02 Jan 2007 15:23:51 -0800 (PST)
Message-ID: <20070102.152351.59657454.davem@davemloft.net>
References: <20070102143906.GA13970@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751336AbXABXXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 18:23:52 -0500
To: hch@lst.de
In-Reply-To: <20070102143906.GA13970@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Tue, 2 Jan 2007 15:39:06 +0100

> All ->doit handlers want a struct rtattr **, so pass down the right
> type.
> 
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

This code was just trying to mirror the typing used by
struct rtnetlink_link's ->doit() method.

But of course you're right in that here the type is always
the same.

Applied, thanks.
