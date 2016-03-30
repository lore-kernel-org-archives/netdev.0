From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bond: set mac address only if necessary
Date: Wed, 30 Mar 2016 15:47:29 -0400 (EDT)
Message-ID: <20160330.154729.2294840883055448558.davem@davemloft.net>
References: <1459264457-19000-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbcC3Trb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 15:47:31 -0400
In-Reply-To: <1459264457-19000-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 29 Mar 2016 15:14:17 +0000

> Bond device gets it's mac address from the first slave device, it's not
> necessary to set slave device's mac address to bond if equal.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

I don't think bond enslavement occurs often enough to justify this
optimization, sorry.
