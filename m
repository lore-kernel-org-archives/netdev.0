From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: Add rudimentary infrastructure to
 account for control chunks
Date: Tue, 13 Aug 2013 15:04:39 -0700 (PDT)
Message-ID: <20130813.150439.445852624627246263.davem@davemloft.net>
References: <52058BB2.4010606@gmail.com>
	<1376100336-21481-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	dborkman@redhat.com, eric.dumazet@gmail.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551Ab3HMWEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:04:43 -0400
In-Reply-To: <1376100336-21481-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Fri,  9 Aug 2013 22:05:36 -0400

> This patch adds a base infrastructure that allows SCTP to do
> memory accounting for control chunks.  Real accounting code will
> follow.
> 
> This patch alos fixes the following triggered bug ...
 ...
> The approach taken here is to split data and control chunks
> creation a  bit.  Data chunks already have memory accounting
> so noting needs to happen.  For control chunks, add stubs handlers.
> 
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, but:

> +	/* TODO: properly account for control chunks. 

I had to delete the trailing whitespace on that line.
