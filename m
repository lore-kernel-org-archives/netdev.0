From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Remove conntrack Kconfig option.
Date: Sun, 06 Sep 2015 23:48:48 -0700 (PDT)
Message-ID: <20150906.234848.1038487585913518678.davem@davemloft.net>
References: <1441397260-61272-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827AbbIGGsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 02:48:53 -0400
In-Reply-To: <1441397260-61272-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Fri,  4 Sep 2015 13:07:40 -0700

> There's no particular desire to have conntrack action support in Open
> vSwitch as an independently configurable bit, rather just to ensure
> there is not a hard dependency. This exposed option doesn't accurately
> reflect the conntrack dependency when enabled, so simplify this by
> removing the option. Compile the support if NF_CONNTRACK is enabled.
> 
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied, thanks.
