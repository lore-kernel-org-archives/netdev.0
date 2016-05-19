From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] kcm: fix a signedness in kcm_splice_read()
Date: Thu, 19 May 2016 11:27:12 -0700 (PDT)
Message-ID: <20160519.112712.1650104301380049541.davem@davemloft.net>
References: <1463519149-5998-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxdev.baldrick@gmail.com,
	tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196AbcESS1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:27:14 -0400
In-Reply-To: <1463519149-5998-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 17 May 2016 14:05:49 -0700

> skb_splice_bits() returns int, kcm_splice_read() returns ssize_t,
> both are signed.
> 
> We may need another patch to make them all ssize_t, but that
> deserves a separated patch.
> 
> Fixes: 91687355b927 ("kcm: Splice support")
> Reported-by: David Binderman <linuxdev.baldrick@gmail.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
