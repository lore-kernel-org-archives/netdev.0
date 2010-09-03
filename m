From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/3] be2net: fix a bug in UE detection logic
Date: Fri, 03 Sep 2010 09:53:53 -0700 (PDT)
Message-ID: <20100903.095353.232911100.davem@davemloft.net>
References: <20100903162321.GA22812@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755815Ab0ICQxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:53:36 -0400
In-Reply-To: <20100903162321.GA22812@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 3 Sep 2010 21:53:30 +0530

> The ONLINE registers can return 0xFFFFFFFF on more than one
> occassion. On systems that care, reading these registers could
> lead to problems.
> 
> So the new code decides that the ASIC has encountered and error
> by reading the UE_STATUS_LOW/HIGH registers. AND them with
> the mask values and a non-zero result indicates an error.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
