From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] llc: fix skb size for test responses
Date: Sun, 24 Feb 2008 18:51:04 -0800 (PST)
Message-ID: <20080224.185104.207884881.davem@davemloft.net>
References: <20080224190758.GW84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: jwestfall@surrealistic.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41866
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752522AbYBYCuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 21:50:22 -0500
In-Reply-To: <20080224190758.GW84358@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Westfall <jwestfall@surrealistic.net>
Date: Sun, 24 Feb 2008 11:07:58 -0800

> Hi
> 
> The llc test command is used for a layer2 ping and contains a variable 
> length payload that we must include in the response.  Use the size of the 
> received skb as the size of the skb we must allocate to hold the payload. 
> 
> This resolved an skb_over_panic(), when trying to copy the payload into 
> what was a hard coded skb of size 128.
> 
> Signed-off-by: Jim Westfall <jwestfall@surrealistic.net>

Arnaldo, please review Jim's patch, thanks!
