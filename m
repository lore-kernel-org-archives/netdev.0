From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] net: rds: use for_each_sg() for
 scatterlist parsing
Date: Mon, 15 Jun 2015 19:56:30 -0700 (PDT)
Message-ID: <20150615.195630.111617476194185511.davem@davemloft.net>
References: <1434388385-29246-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chien.yen@oracle.com,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbbFPC4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 22:56:31 -0400
In-Reply-To: <1434388385-29246-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 15 Jun 2015 19:13:05 +0200

>  {
>  	unsigned int i;
> +	struct scatterlist *sg;

Please order local variables from longest to shortest line (reverse
christmas tree).

Thanks.
