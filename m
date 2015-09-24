From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] fib_rules: fix fib rule dumps across multiple skbs
Date: Thu, 24 Sep 2015 15:22:30 -0700 (PDT)
Message-ID: <20150924.152230.1137654723404286423.davem@davemloft.net>
References: <1442983222-42750-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbbIXWWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 18:22:31 -0400
In-Reply-To: <1442983222-42750-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 22 Sep 2015 21:40:22 -0700

> From: Wilson Kok <wkok@cumulusnetworks.com>
> 
> dump_rules returns skb length and not error.
> But when family == AF_UNSPEC, the caller of dump_rules
> assumes that it returns an error. Hence, when family == AF_UNSPEC,
> we continue trying to dump on -EMSGSIZE errors resulting in
> incorrect dump idx carried between skbs belonging to the same dump.
> This results in fib rule dump always only dumping rules that fit
> into the first skb.
> 
> This patch fixes dump_rules to return error so that we exit correctly
> and idx is correctly maintained between skbs that are part of the
> same dump.
> 
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
