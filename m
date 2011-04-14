From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bna: fix memory leak during RX path cleanup
Date: Thu, 14 Apr 2011 13:40:03 -0700 (PDT)
Message-ID: <20110414.134003.71113677.davem@davemloft.net>
References: <1302804319-15677-1-git-send-email-rmody@brocade.com>
	<1302804319-15677-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752041Ab1DNUki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 16:40:38 -0400
In-Reply-To: <1302804319-15677-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Thu, 14 Apr 2011 11:05:19 -0700

> The memory leak was caused by unintentional assignment of the Rx path
> destroy callback function pointer to NULL just after correct
> initialization.
> 
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied.
