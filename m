From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv4: fix redirect handling for TCP packets
Date: Mon, 27 May 2013 23:40:08 -0700 (PDT)
Message-ID: <20130527.234008.2288985801653974436.davem@davemloft.net>
References: <20130527.232350.1126293930261151421.davem@davemloft.net>
	<20130528063301.11B7662C67@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464Ab3E1GkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:40:09 -0400
In-Reply-To: <20130528063301.11B7662C67@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue, 28 May 2013 08:26:49 +0200

> Unlike ipv4_redirect() and ipv4_sk_redirect(), ip_do_redirect()
> doesn't call __build_flow_key() directly but via
> ip_rt_build_flow_key() wrapper. This leads to __build_flow_key()
> getting pointer to IPv4 header of the ICMP redirect packet
> rather than pointer to the embedded IPv4 header of the packet
> initiating the redirect.
> 
> As a result, handling of ICMP redirects initiated by TCP packets
> is broken. Issue was introduced by
> 
> 	4895c771c ("ipv4: Add FIB nexthop exceptions.")
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied, thanks!
