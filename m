From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Fri, 13 Mar 2015 00:10:07 -0400 (EDT)
Message-ID: <20150313.001007.65274068513753002.davem@davemloft.net>
References: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbCMEKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 00:10:11 -0400
In-Reply-To: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Thu, 12 Mar 2015 17:29:55 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This series moves bridge stp update api to follow the setlink/dellink
> apis to propagate stp state updates to switch ports on stacked netdevs
> 
> v1 -> v2:
> 	fix comment
> 	add CONFIG_NET_SWITCHDEV checks
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Can't we just do this stacked device traveral transparently?

That seems much cleaner to me.
