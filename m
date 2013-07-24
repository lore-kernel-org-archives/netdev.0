From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vti: switch to new ip tunnel code
Date: Tue, 23 Jul 2013 17:28:30 -0700 (PDT)
Message-ID: <20130723.172830.574804811812171184.davem@davemloft.net>
References: <1374374785-30291-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	stephen@networkplumber.org, saurabh.mohan@vyatta.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3GXA2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 20:28:31 -0400
In-Reply-To: <1374374785-30291-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sun, 21 Jul 2013 10:46:25 +0800

> GRE tunnel and IPIP tunnel already switched to the new
> ip tunnel code, VTI tunnel can use it too.
> 
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Saurabh Mohan <saurabh.mohan@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Nice work, applied, thanks.

>  net/ipv4/ip_vti.c |  528 ++++++-----------------------------------------------
>  1 files changed, 52 insertions(+), 476 deletions(-)

I'll apply almost any patch that has this kind of diffstat :-)
