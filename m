From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: netlink: make br_fill_info's frame
 size smaller
Date: Wed, 07 Oct 2015 04:16:32 -0700 (PDT)
Message-ID: <20151007.041632.1792983203247554518.davem@davemloft.net>
References: <201510051053.L0S9UKIW%fengguang.wu@intel.com>
	<1444039881-8818-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbbJGLAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:00:47 -0400
In-Reply-To: <1444039881-8818-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon,  5 Oct 2015 12:11:21 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> When KASAN is enabled the frame size grows > 2048 bytes and we get a
> warning, so make it smaller.
> net/bridge/br_netlink.c: In function 'br_fill_info':
>>> net/bridge/br_netlink.c:1110:1: warning: the frame size of 2160 bytes
>>> is larger than 2048 bytes [-Wframe-larger-than=]
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
