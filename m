From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] ADDRCONF: Fix default source address selection without
 CONFIG_IPV6_PRIVACY
Date: Thu, 22 Jun 2006 01:42:45 -0700 (PDT)
Message-ID: <20060622.014245.106265721.davem@davemloft.net>
References: <20060622.002341.04738770.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54173
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751226AbWFVImp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:42:45 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060622.002341.04738770.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 22 Jun 2006 00:23:41 +0900 (JST)

> We need to update hiscore.rule even if we don't enable CONFIG_IPV6_PRIVACY,
> because we have more less significant rule; longest match.

Applied, thank you.

> I think it is suitable for -stable as well.

Agreed, I have pushed it to -stable.
