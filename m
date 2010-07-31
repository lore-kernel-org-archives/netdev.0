From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] be2net: fix to avoid sending get_stats
 request if one is already being processed.
Date: Fri, 30 Jul 2010 23:59:40 -0700 (PDT)
Message-ID: <20100730.235940.35038438.davem@davemloft.net>
References: <20100729161849.GA15529@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755195Ab0GaG7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:59:22 -0400
In-Reply-To: <20100729161849.GA15529@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Thu, 29 Jul 2010 21:48:58 +0530

> GET_STATS request uses the same memory region as the response.
> If a new request for get stats is fired before the response for
> the previous get_stats request is received, the response will
> corrupt the new request, causing the f/w to misbehave.
> 
> Signed-off-by: Somnath K <somnathk@serverengines.com>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
