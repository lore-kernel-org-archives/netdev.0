From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] ipv6: copy lwtstate in ip6_rt_copy_init()
Date: Fri, 24 Jul 2015 06:40:20 -0700
Message-ID: <55B24044.4010406@cumulusnetworks.com>
References: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35517 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbGXNkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 09:40:23 -0400
Received: by pdrg1 with SMTP id g1so14059088pdr.2
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 06:40:23 -0700 (PDT)
In-Reply-To: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/15, 3:28 AM, Nicolas Dichtel wrote:
> We need to copy this field (ip6_rt_cache_alloc() and ip6_rt_pcpu_alloc()
> use ip6_rt_copy_init() to build a dst).
>
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 19e42e451506 ("ipv6: support for fib route lwtunnel encap attributes")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks!
