From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v3 0/2] Multicast processing in IPvlan
Date: Tue, 05 May 2015 19:30:03 -0400 (EDT)
Message-ID: <20150505.193003.1859381402714129421.davem@davemloft.net>
References: <1430784356-2049-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, dcbw@redhat.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbbEEXaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:30:05 -0400
In-Reply-To: <1430784356-2049-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Mon,  4 May 2015 17:05:56 -0700

> Dan Willems pointed out that autoconf in IPvlan is broken because of the
> way broadcast bit gets set. Since broadcast processing is a real performance
> drain, the broadcast bit in multicast filter was only set when the interface
> was configured with IPv4 address. In autoconf scenario, when there are
> no addresses configured; this logic did not work and it wouldn't allow
> DHCPv4 to work. The only way was to add protocol specific hacks to avoid
> processing unnecessary broadcast burdon.
> 
> This jugglery could be avoided if these multicast / broadcast packets are taken
> out of fast-path and are processed in a work-queue. This will enable us to add
> broadcast bit in all multicast filters without any impact on performance of
> the virtual device. This patch series just does that.

Series applied, thanks.
