From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/4]: Fix several errors in extension header handling.
Date: Tue, 18 Apr 2006 14:49:14 -0700 (PDT)
Message-ID: <20060418.144914.24796175.davem@davemloft.net>
References: <20060419.002045.85775401.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12434
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750713AbWDRVtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 17:49:16 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060419.002045.85775401.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 19 Apr 2006 00:20:45 +0900 (JST)

> Following changesets fix several errors in extension header handling.
> I'd propose to push them (except 4/4, maybe) to -stable.
> 
> [PATCH 1/4] [IPV6]: Ensure to have hop-by-hop options in our header of &sk_buff.
> [PATCH 2/4] [IPV6] XFRM: Don't use old copy of pointer after pskb_may_pull().
> [PATCH 3/4] [IPV6] XFRM: Fix decoding session with preceding extension header(s).
> [PATCH 4/4] [IPV6]: Clean up hop-by-hop options handler.

All applied, and I agree with pushing 1-3 into -stable,
please send it.

