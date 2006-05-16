From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed at net/* (again)
Date: Tue, 16 May 2006 14:51:21 +0400
Message-ID: <20060516105121.GA18677@2ka.mipt.ru>
References: <16537920-30DB-4FF7-BD51-DC8517BF4321@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	grsecurity@grsecurity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:4810 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751770AbWEPKvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 06:51:25 -0400
To: Chris Boot <bootc@bootc.net>
Content-Disposition: inline
In-Reply-To: <16537920-30DB-4FF7-BD51-DC8517BF4321@bootc.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006 at 11:38:38AM +0100, Chris Boot (bootc@bootc.net) wrote:
> May 16 09:15:12 baldrick kernel: [6442250.504000] KERNEL: assertion (! 
> sk->sk_forward_alloc) failed at net/core/stream.c (283)
> May 16 09:15:12 baldrick kernel: [6442250.513000] KERNEL: assertion (! 
> sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (150)
> 
> tcp segmentation offload: on

This bug was fixed in .10 in stack and .12 in e1000 driver 
(probably unrelated to your problem, if you do not have packet plit
option enabled).

> Many thanks,
> Chris

-- 
	Evgeniy Polyakov
