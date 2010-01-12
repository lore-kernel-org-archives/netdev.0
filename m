From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Mon, 11 Jan 2010 16:28:13 -0800 (PST)
Message-ID: <20100111.162813.45985102.davem@davemloft.net>
References: <20100110220034.4d46ba8a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100110220034.4d46ba8a@nehalam>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Date: Sun, 10 Jan 2010 22:00:34 -0800

> This patch adds the kernel portions needed to implement
> RFC 5082 Generalized TTL Security Mechanism (GTSM).
> It is a lightweight security measure against forged
> packets causing DoS attacks (for BGP). 
> 
> This is already implemented the same way in BSD kernels.
> For the necessary Quagga patch 
>   http://www.gossamer-threads.com/lists/quagga/dev/17389
> 
> Description from Cisco
>   http://www.cisco.com/en/US/docs/ios/12_3t/12_3t7/feature/guide/gt_btsh.html
> 
> It does add one byte to each socket structure, but I did
> a little rearrangement to reuse a hole (on 64 bit), but it
> does grow the structure on 32 bit
> 
> This should be documented on ip(4) man page and the Glibc in.h
> file also needs update.  IPV6_MINHOPLIMIT should also be added
> (although BSD doesn't support that).  
> 
> Only TCP is supported, but could also be added to UDP, DCCP, SCTP
> if desired.
> 
> Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

Applied to net-next-2.6, thanks Stephen.
