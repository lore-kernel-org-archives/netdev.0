From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: prevent bridging wrong device
Date: Thu, 05 Nov 2009 21:08:13 -0800 (PST)
Message-ID: <20091105.210813.230480395.davem@davemloft.net>
References: <20091029152408.6c6cc29f@nehalam>
	<20091102.000756.222203879.davem@davemloft.net>
	<20091104094713.1983a0b6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nneul@mst.edu, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52488
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750883AbZKFFHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:47 -0500
In-Reply-To: <20091104094713.1983a0b6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Nov 2009 09:47:13 -0800

> The bridge code assumes ethernet addressing, so be more strict in
> the what is allowed. This showed up when GRE had a bug and was not
> using correct address format.
> 
> Add some more comments for increased clarity.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6, thanks.
