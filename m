From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/4] be2net: don't rearm mcc cq when
 device is not open
Date: Wed, 17 Feb 2010 13:50:01 -0800 (PST)
Message-ID: <20100217.135001.243010306.davem@davemloft.net>
References: <20100217113511.GA19873@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757443Ab0BQVtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:49:45 -0500
In-Reply-To: <20100217113511.GA19873@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 17 Feb 2010 17:05:11 +0530

> When an MCC cmd is issued (via a netdev/ethtool op)
> while the device is not open, the MCC CQ gets processed but the EQ
> is not processed (as isr is not registered.) This can cause the EQ
> to become full. So, while the device is not open, CQ must not be re-armed
> to prevent EQ entries.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
