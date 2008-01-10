From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [NEIGH] Make /proc/net/arp opening consistent
 with seq_net_open semantics
Date: Thu, 10 Jan 2008 03:53:37 -0800 (PST)
Message-ID: <20080110.035337.195644262.davem@davemloft.net>
References: <20080110113219.GA16233@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, xemul@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43251
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753382AbYAJLxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 06:53:42 -0500
In-Reply-To: <20080110113219.GA16233@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 10 Jan 2008 14:32:19 +0300

> seq_open_net requires that first field of the seq->private data to be
> struct seq_net_private. In reality this is a single pointer to a struct net
> for now. The patch makes code consistent.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks for correcting this.
