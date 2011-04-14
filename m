From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bna: fix for clean fw re-initialization
Date: Thu, 14 Apr 2011 13:39:57 -0700 (PDT)
Message-ID: <20110414.133957.226775217.davem@davemloft.net>
References: <1302804319-15677-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751152Ab1DNUkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 16:40:33 -0400
In-Reply-To: <1302804319-15677-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Thu, 14 Apr 2011 11:05:18 -0700

> During a kernel crash, bna control path state machine and firmware do not
> get a notification and hence are not cleanly shutdown. The registers
> holding driver/IOC state information are not reset back to valid
> disabled/parking values. This causes subsequent driver initialization
> to hang during kdump kernel boot. This patch, during the initialization
> of first PCI function, resets corresponding register when unclean shutown
> is detect by reading chip registers. This will make sure that ioc/fw
> gets clean re-initialization.
> 
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied.
