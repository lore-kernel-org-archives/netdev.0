From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix possible use of uninitialized in
 vxlan_igmp_{join,leave}
Date: Fri, 20 Mar 2015 13:31:50 -0400 (EDT)
Message-ID: <20150320.133150.1173308455913235913.davem@davemloft.net>
References: <1426857981-17946-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbbCTRbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:31:52 -0400
In-Reply-To: <1426857981-17946-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 20 Mar 2015 10:26:21 -0300

> Test robot noticed that we check the return of vxlan_igmp_join and leave
> but inside them there was a path that it could be used initialized.
> 
> It's not really possible because those if() inside these igmp functions
> would always match as we can't have sockets of other type in there, but
> this way we keep the compiler happy.
> 
> Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks.
