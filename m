From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2 v2] bonding: COW before overwriting the destination
 MAC address
Date: Thu, 3 Mar 2011 16:21:12 +0800
Message-ID: <AANLkTimNb-ZPFuhhdsSroFzaHKFauR3pTBXL3HMmnECf@mail.gmail.com>
References: <1299136034-5549-1-git-send-email-xiaosuo@gmail.com> <1299138901.2456.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63116 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756408Ab1CCIVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:21:34 -0500
Received: by fxm17 with SMTP id 17so852575fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 00:21:32 -0800 (PST)
In-Reply-To: <1299138901.2456.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2011 at 3:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
>
> Thats minor, but using :
>
> u16 *dest = eth_hdr(skb)->h_dest;
>
> memcpy(dest, ptr, ETH_ALEN);
>
> Is better because compiler knows both destination and source are at
> least aligned on shorts.
>
> On some arches, it helps to not using 6 bytes copy, but 3 shorts.
>
>

Is it still true if ptr isn't aligned on shorts? And
net_device.dev_addr is an unsigned char *pointer. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
