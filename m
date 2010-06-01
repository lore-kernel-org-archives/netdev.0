From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] be2net: replace udelay() with
 schedule_timeout() in mbox polling
Date: Tue, 01 Jun 2010 00:19:57 -0700 (PDT)
Message-ID: <20100601.001957.173874479.davem@davemloft.net>
References: <20100531093414.GA2867@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411Ab0FAHTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:19:48 -0400
In-Reply-To: <20100531093414.GA2867@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 31 May 2010 15:04:14 +0530

> As mbox polling is done only in process context, it is better to
> use schedule_timeout() instead of udelay().
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
