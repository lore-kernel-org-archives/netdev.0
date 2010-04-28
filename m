From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Wed, 28 Apr 2010 14:25:34 -0700 (PDT)
Message-ID: <20100428.142534.57451492.davem@davemloft.net>
References: <1272477251.18228.36.camel@Joe-Laptop.home>
	<20100428111354.49a6ec1a@nehalam>
	<20100428112528.01277670@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, therbert@google.com, netdev@vger.kernel.org,
	aabdulla@nvidia.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59895
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755351Ab0D1VZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 17:25:29 -0400
In-Reply-To: <20100428112528.01277670@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 28 Apr 2010 11:25:28 -0700

> The following does the same thing without the extra overhead
> of testing all the registers. It also handles the out of memory
> case.
> 
> Compile tested only...
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Tom can you test this version?
