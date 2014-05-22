From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] batman: fix a bogus warning from
 batadv_is_on_batman_iface()
Date: Thu, 22 May 2014 17:23:13 -0400 (EDT)
Message-ID: <20140522.172313.1010680178989682498.davem@davemloft.net>
References: <1400785037-9963-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jet.chen@intel.com,
	steffen.klassert@secunet.com, antonio@open-mesh.com,
	mareklindner@neomailbox.ch, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaEVVXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 17:23:15 -0400
In-Reply-To: <1400785037-9963-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 22 May 2014 11:57:17 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> batman tries to search dev->iflink to check if it's a batman interface,
> but ->iflink could be 0, which is not a valid ifindex. It should just
> avoid iflink == 0 case.
> 
> Reported-by: Jet Chen <jet.chen@intel.com>
> Tested-by: Jet Chen <jet.chen@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Antonio Quartulli <antonio@open-mesh.com>
> Cc: Marek Lindner <mareklindner@neomailbox.ch>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied, thank you.
