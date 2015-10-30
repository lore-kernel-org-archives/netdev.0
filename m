From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 2/3] geneve: handle ipv6 priority like ipv4 tos
Date: Fri, 30 Oct 2015 12:11:47 +0900 (KST)
Message-ID: <20151030.121147.1352235120337774737.davem@davemloft.net>
References: <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
	<1445893306-31225-1-git-send-email-linville@tuxdriver.com>
	<1445893306-31225-2-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jesse@nicira.com,
	jbenc@redhat.com, hideaki.yoshifuji@miraclelinux.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757892AbbJ3DLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 23:11:55 -0400
In-Reply-To: <1445893306-31225-2-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 26 Oct 2015 17:01:45 -0400

> Other callers of udp_tunnel6_xmit_skb just pass 0 for the prio
> argument.  Jesse Gross <jesse@nicira.com> suggested that prio is really
> the same as IPv4's tos and should be handled the same, so this is my
> interpretation of that suggestion.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Reported-by: Jesse Gross <jesse@nicira.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>

Applied.
