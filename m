From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/tipc/port.c: fix NULL dereference
Date: Tue, 31 Oct 2006 16:59:46 -0800 (PST)
Message-ID: <20061031.165946.126763326.davem@davemloft.net>
References: <20061101004037.GZ27968@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60585
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1945968AbWKAA7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 19:59:46 -0500
To: bunk@stusta.de
In-Reply-To: <20061101004037.GZ27968@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 1 Nov 2006 01:40:37 +0100

> The correct order is: NULL check before dereference
> 
> Spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
