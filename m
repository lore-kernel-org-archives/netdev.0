From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 1/23] [PATCH] [XFRM]: Add XFRM_MODE_xxx for future use.
Date: Wed, 02 Aug 2006 10:34:44 +0900
Message-ID: <44D00134.90006@linux-ipv6.org>
References: <11541653852481-git-send-email-nakam@linux-ipv6.org> <20060801.165232.95060501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:56721 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1750961AbWHBBez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 21:34:55 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.165232.95060501.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Sat, 29 Jul 2006 18:29:45 +0900
> 
>> Transformation mode is used as either IPsec transport or tunnel.
>> It is required to add two more items, route-optimization and inbound trigger
>> by Mobile IPv6.
>> Based on MIPL2 kernel patch.
> 
> This change looks fine, but please explain the inconsistent
> transformation done in xfrm4_encap() vs. xfrm6_encap().
> 
[snip]
> Unless there is a reason to do things differently, we should make the
> checks identical even if ipv4 will never use values other than
> XFRM_MODE_TUNNEL and XFRM_MODE_TRANSPORT.


Oops, I'm sorry, both should be the same.
My fix wants to change it as xfrm6_encap case, then I'll fix xfrm4_encap.

And I will check all patches with that point.

Thanks,

-- 
Masahide NAKAMURA
