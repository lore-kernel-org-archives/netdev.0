From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Annotate uninitialized var in sfq_enqueue()
Date: Sun, 21 Dec 2008 20:15:03 -0800 (PST)
Message-ID: <20081221.201503.134384041.davem@davemloft.net>
References: <20081219084407.GC7189@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752481AbYLVEPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:15:01 -0500
In-Reply-To: <20081219084407.GC7189@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 19 Dec 2008 08:44:07 +0000

> Some gcc versions warn that ret may be used uninitialized in
> sfq_enqueue(). It's a false positive, so let's annotate this.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied to net-next-2.6, thanks Jarek.
