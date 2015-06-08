From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Mon, 08 Jun 2015 12:16:01 -0700 (PDT)
Message-ID: <20150608.121601.1357405469784892473.davem@davemloft.net>
References: <1433779259-14328-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, tom@herbertland.com
To: johunt@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbbFHTQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:16:02 -0400
In-Reply-To: <1433779259-14328-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>
Date: Mon,  8 Jun 2015 12:00:59 -0400

> UDP encapsulation is broken on IPv6. This is because the logic to resubmit
> the nexthdr is inverted, checking for a ret value > 0 instead of < 0. Also,
> the resubmit label is in the wrong position since we already get the
> nexthdr value when performing decapsulation. In addition the skb pull is no
> longer necessary either.
> 
> This changes the return value check to look for < 0, using it for the
> nexthdr on the next iteration, and moves the resubmit label to the proper
> location.
> 
> With these changes the v6 code now matches what we do in the v4 ip input
> code wrt resubmitting when decapsulating.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>

Applied.
