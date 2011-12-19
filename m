From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Do not account for sizeof(struct sk_buff) in
 estimated rwnd
Date: Mon, 19 Dec 2011 15:10:04 -0500 (EST)
Message-ID: <20111219.151004.851224380823448122.davem@davemloft.net>
References: <1324303900-8360-1-git-send-email-tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: tgraf@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab1LSUKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 15:10:20 -0500
In-Reply-To: <1324303900-8360-1-git-send-email-tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@redhat.com>
Date: Mon, 19 Dec 2011 15:11:40 +0100

> When checking whether a DATA chunk fits into the estimated rwnd a
> full sizeof(struct sk_buff) is added to the needed chunk size. This
> quickly exhausts the available rwnd space and leads to packets being
> sent which are much below the PMTU limit. This can lead to much worse
> performance.
 ...

Vlad, please review this.

Thanks.
