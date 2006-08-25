From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension headers sorting.
Date: Fri, 25 Aug 2006 23:29:05 +0900
Message-ID: <20060825232819.66C6.NAKAM@linux-ipv6.org>
References: <44EECBB0.7070001@linux-ipv6.org> <20060825.031651.88475974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:8620 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751452AbWHYO3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 10:29:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060825.031651.88475974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006 03:16:51 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Fri, 25 Aug 2006 19:06:40 +0900
> 
> > I've found a problem about MIPv6 CN with the patch below.
> 
> We just need to search by priority in the inexact list, even
> if we get a hit in the hash table.
> 
> The fix is trivial, please try this patch:


Thank you for providing it quickly.
It works! 

I continue my test with this patch for now to confirm other features.

Regards,

-- 
Masahide NAKAMURA

