From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bridge: handle process all link-local frames
Date: Tue, 17 Jun 2008 16:11:19 -0700 (PDT)
Message-ID: <20080617.161119.223649778.davem@davemloft.net>
References: <20080617165211.615620784@vyatta.com>
	<20080617165223.110719400@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760952AbYFQXLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:11:19 -0400
In-Reply-To: <20080617165223.110719400@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 17 Jun 2008 09:52:12 -0700

> Any frame addressed to link-local addresses should be processed by local
> receive path. The earlier code would process them only if STP was enabled.
> Since there are other frames like LACP for bonding, we should always
> process them.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
