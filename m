From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: include net/ip6_checksum.h for
 csum_ipv6_magic()
Date: Mon, 02 Sep 2013 21:01:26 -0700 (PDT)
Message-ID: <20130902.210126.899564840478397021.davem@davemloft.net>
References: <1378087613-15279-1-git-send-email-amwang@redhat.com>
	<1378087613-15279-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab3ICDzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 23:55:20 -0400
In-Reply-To: <1378087613-15279-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  2 Sep 2013 10:06:52 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Fengguang reported a compile warning:
> 
>    drivers/net/vxlan.c: In function 'vxlan6_xmit_skb':
>    drivers/net/vxlan.c:1352:3: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
>    cc1: some warnings being treated as errors
> 
> this patch fixes it.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
