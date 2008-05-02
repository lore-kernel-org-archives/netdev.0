From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: forwarding table information for >256 devices
Date: Fri, 02 May 2008 16:53:48 -0700 (PDT)
Message-ID: <20080502.165348.226972498.davem@davemloft.net>
References: <20080501134209.3012de69@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763477AbYEBXxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:53:48 -0400
In-Reply-To: <20080501134209.3012de69@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 1 May 2008 13:42:09 -0700

> The forwarding table binary interface (my bad choice), only exposes the
> port number of the first 8 bits. The bridge code was limited to 256 ports
> at the time, but now the kernel supports up 1024 ports, so the upper bits
> are lost when doing:
>    brctl showmacs
> 
> The fix is to squeeze the extra bits into small hole left in data structure,
> to maintain binary compatiablity.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

At least you had somewhere to stick the high bits :)

Applied, thanks.
