From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cxgb3: fix 2 ports 1G regression
Date: Wed, 05 Aug 2009 20:28:39 -0700 (PDT)
Message-ID: <20090805.202839.79597369.davem@davemloft.net>
References: <20090805215923.21467.99484.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbZHFD2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 23:28:30 -0400
In-Reply-To: <20090805215923.21467.99484.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 05 Aug 2009 14:59:23 -0700

> commit 88045b3cf0f8981129cb489c7b6bc36c21dd33a7
> 	cxgb3: fix mac index mapping
> 
> 	Override the mac index computation for the gen2 adapter,
> 	as each port is expected to use index 0.
> 
> introduces a regression on 2 port 1G adapter
> as its xauicfg vpd value is null.
> Add a check on the device id.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied, thanks.
