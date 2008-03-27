From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-2.6.26] [NETNS]: Do no include NET related
 headers if CONFIG_NET is not set.
Date: Thu, 27 Mar 2008 14:27:09 -0700 (PDT)
Message-ID: <20080327.142709.140236839.davem@davemloft.net>
References: <20080327.022206.100283150.davem@davemloft.net>
	<1206613797-32045-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, --cc@sw.ru
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759031AbYC0V1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 17:27:08 -0400
In-Reply-To: <1206613797-32045-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 27 Mar 2008 13:29:57 +0300

> This fix broken compilation for 'allnoconfig'. This was introduced by
> Introduced by commit 1218854afa6f659be90b748cf1bc7badee954a35 ("[NET]
> NETNS: Omit seq_net_private->net without CONFIG_NET_NS.")
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks a lot!
