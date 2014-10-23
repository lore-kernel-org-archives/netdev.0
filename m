From: Crestez Dan Leonard <cdleonard@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 16:03:13 +0300
Message-ID: <5448FC91.6010206@gmail.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com> <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:58051 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445AbaJWNDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 09:03:17 -0400
Received: by mail-wg0-f42.google.com with SMTP id z12so1043450wgg.13
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 06:03:16 -0700 (PDT)
In-Reply-To: <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 08:38 AM, Eric Dumazet wrote:
> On Wed, 2014-10-22 at 22:23 -0700, Eric Dumazet wrote:
> My updated patch would be :
> 
>  net/ipv4/tcp.c |   66 +++++++++++++++++++----------------------------
>  1 file changed, 28 insertions(+), 38 deletions(-)
> 
I can confirm that this patch fixes my original issue.

I am working with a kernel based on 3.10 so I had to integrate 71cea17ed39fdf1c0634f530ddc6a2c2fc601c2b as well.

Regards,
Leonard
