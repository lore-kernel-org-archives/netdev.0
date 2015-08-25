From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] route: fix a use-after-free
Date: Tue, 25 Aug 2015 14:29:56 -0700 (PDT)
Message-ID: <20150825.142956.598034581881826054.davem@davemloft.net>
References: <1440524333-5902-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbHYV34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:29:56 -0400
In-Reply-To: <1440524333-5902-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 25 Aug 2015 10:38:53 -0700

> This patch fixes the following crash:
 ...
> dst is freed right before lwtstate_put(), this is not correct...
> 
> Fixes: 61adedf3e3f1 ("route: move lwtunnel state to dst_entry")
> Acked-by: Jiri Benc <jbenc@redhat.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied, thanks.
