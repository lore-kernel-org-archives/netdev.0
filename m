From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] ipv6: copy lwtstate in ip6_rt_copy_init()
Date: Fri, 24 Jul 2015 12:40:47 +0200
Message-ID: <20150724104047.GA15706@pox.localdomain>
References: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38724 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbbGXKkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 06:40:51 -0400
Received: by wibxm9 with SMTP id xm9so22105307wib.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 03:40:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/15 at 12:28pm, Nicolas Dichtel wrote:
> We need to copy this field (ip6_rt_cache_alloc() and ip6_rt_pcpu_alloc()
> use ip6_rt_copy_init() to build a dst).
> 
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 19e42e451506 ("ipv6: support for fib route lwtunnel encap attributes")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
