From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] cxgb4: keep interrupts available when the ports
 are brought down
Date: Tue, 18 May 2010 15:17:03 -0700 (PDT)
Message-ID: <20100518.151703.190396491.davem@davemloft.net>
References: <1274213233-26309-1-git-send-email-dm@chelsio.com>
	<1274213233-26309-2-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755320Ab0ERWQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:16:54 -0400
In-Reply-To: <1274213233-26309-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 18 May 2010 13:07:12 -0700

> The PF driver needs to remain alert while its ports are down to service
> requests or errors from virtual functions or FW so keep interrupts and
> queues available when the ports are brought down.  The change makes
> open_device_map unnecessary so remove it.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied.
