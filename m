From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] ldmvsw: Split sunvnet driver into common
 code
Date: Fri, 11 Mar 2016 14:26:24 -0500 (EST)
Message-ID: <20160311.142624.309634155348470545.davem@davemloft.net>
References: <cover.1457401532.git.Aaron.Young@oracle.com>
	<cover.1457401532.git.Aaron.Young@oracle.com>
	<25112e068360c00b9737797df40a3a6f25a3cd22.1457401532.git.Aaron.Young@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	alexandre.chartre@oracle.com, rashmi.narasimhan@oracle.com
To: Aaron.Young@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075AbcCKT01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:26:27 -0500
In-Reply-To: <25112e068360c00b9737797df40a3a6f25a3cd22.1457401532.git.Aaron.Young@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Young <Aaron.Young@oracle.com>
Date: Tue,  8 Mar 2016 07:02:33 -0800

> +EXPORT_SYMBOL(vnet_send_attr_common);

All of these need to be EXPORT_SYMBOL_GPL()
