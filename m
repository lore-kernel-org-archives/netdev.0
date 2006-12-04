From: David Miller <davem@davemloft.net>
Subject: Re: (usagi-core 31727) Re: [PATCH][IPSEC][6/7] inter address
 family ipsec tunnel
Date: Sun, 03 Dec 2006 22:33:36 -0800 (PST)
Message-ID: <20061203.223336.71087901.davem@davemloft.net>
References: <45738CE1.3070304@miyazawa.org>
	<20061203.191208.74749805.davem@davemloft.net>
	<4573A375.7010100@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38888
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S934363AbWLDGdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 01:33:36 -0500
To: kazunori@miyazawa.org
In-Reply-To: <4573A375.7010100@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Mon, 04 Dec 2006 13:26:29 +0900

> If uninitialized ut->family is AF_INET or AF_INET6 by chance
> and the family of outer addresses (ut->saddr) is differnt
> ut->family, it results some garbage in the kernel as you know.
> 
> I think it does not results any oops or a segmentation fault
> because xfrm_address always has enough length (16 bytes) to wrong
> access.
> 
>  From the point of view of security, the policy has garbege
> templates, but the selector is valid and it mangates applying
> IPsec. So it result blocking the traffic.
> Accordingly, I think it falls down to secure side.

Yes, I am beginning to think it is safe too.
