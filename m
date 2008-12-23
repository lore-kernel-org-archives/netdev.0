From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix oops in dev_ifsioc()
Date: Mon, 22 Dec 2008 19:35:33 -0800 (PST)
Message-ID: <20081222.193533.101212522.davem@davemloft.net>
References: <20081219070431.GA7189@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbYLWDfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 22:35:31 -0500
In-Reply-To: <20081219070431.GA7189@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 19 Dec 2008 07:04:31 +0000

> A command like this: "brctl addif br1 eth1" issued as a user gave me
> an oops when bridge module wasn't loaded. It's caused by using a dev
> pointer before checking for NULL.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
