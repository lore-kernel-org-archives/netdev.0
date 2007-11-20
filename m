From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 2/6] net: Make rtnetlink infrastructure network
 namespace aware (v3)
Date: Mon, 19 Nov 2007 22:33:37 -0800 (PST)
Message-ID: <20071119.223337.231711248.davem@davemloft.net>
References: <20071115155741.GA25443@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753055AbXKTGdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:33:38 -0500
In-Reply-To: <20071115155741.GA25443@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 15 Nov 2007 18:57:41 +0300

> After this patch none of the netlink callback support anything
> except the initial network namespace but the rtnetlink infrastructure
> now handles multiple network namespaces.
> 
> Changes from v2:
> - IPv6 addrlabel processing
> 
> Changes from v1:
> - no need for special rtnl_unlock handling
> - fixed IPv6 ndisc
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
