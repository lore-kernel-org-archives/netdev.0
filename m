From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] net: ipv6: add IPSKB_REROUTED exclusion to
 NF_HOOK/POSTROUTING invocation
Date: Thu, 01 Apr 2010 01:34:53 -0700 (PDT)
Message-ID: <20100401.013453.223306499.davem@davemloft.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
	<1270031934-15940-3-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754300Ab0DAIew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 04:34:52 -0400
In-Reply-To: <1270031934-15940-3-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Wed, 31 Mar 2010 12:38:50 +0200

> Similar to how IPv4's ip_output.c works, have ip6_output also check
> the IPSKB_REROUTED flag. It will be set from xt_TEE for cloned packets
> since Xtables can currently only deal with a single packet in flight
> at a time.
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

I defer to ipv6 experts as to whether this will cause trouble
or not.

If they are fine with it, feel free to add my:

Acked-by: David S. Miller <davem@davemloft.net>

and this can go in via the nf tree along with the other changes in
this set.

Thanks.
