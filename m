From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] myri10ge: allow to disable link status change reporting
Date: Mon, 14 Aug 2006 18:02:30 -0400
Message-ID: <44E0F2F6.7020403@garzik.org>
References: <44E0DA08.9080304@myri.com> <44E0F0C1.8000408@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62884 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964986AbWHNWCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 18:02:33 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <44E0F0C1.8000408@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Add myri10ge_verbose module parameter to disable reporting of
> link status change since some Ethernet switches seem to generate
> a lot of status changes under some circumstances and some people
> want to avoid useless flooding in the logs.
> 
> Also add a counter for link status changes to statistics.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

NAK - use the standard netif_msg_xxx and the msg_enable style variable 
found in many drivers.  No need for a module parameter, ethtool already 
covers this type of need.

	Jeff



