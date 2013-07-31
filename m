From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Tue, 30 Jul 2013 23:26:39 -0700 (PDT)
Message-ID: <20130730.232639.178259761581407616.davem@davemloft.net>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
	<1375240090.10515.53.camel@edumazet-glaptop>
	<1375240402.22980.5.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, ycheng@google.com, ncardwell@google.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab3GaG0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 02:26:42 -0400
In-Reply-To: <1375240402.22980.5.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 31 Jul 2013 11:13:22 +0800

> I know saving 8 bytes is not interesting for you, but it is for me,
> since I need some room in struct tcp_metrics_block for union inet_addr.
> With this patch, I don't have to make struct tcp_metrics_block expand to
> 3 cachelines. :)

Cong, please.

Instead of making code accomodate an unnecessarily large "union
inet_addr", make a small version of it that accomodates this use case
and doesn't have the extra fields.
