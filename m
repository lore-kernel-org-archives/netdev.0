From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] be2net: Bug fix to send config commands to
 hardware after netdev_register
Date: Fri, 06 Nov 2009 20:26:29 -0800 (PST)
Message-ID: <20091106.202629.175405648.davem@davemloft.net>
References: <20091106120720.GA19198@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56757
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760162AbZKGE0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:26:03 -0500
In-Reply-To: <20091106120720.GA19198@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 6 Nov 2009 17:37:32 +0530

> Sending config commands to be2 hardware before netdev_register is
> completed, is sometimes causing the async link notification to arrive
> even before the driver is ready to handle it. The commands for vlan
> config and flow control settings can infact wait till be_open.
> This patch takes care of that.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied to net-2.6
