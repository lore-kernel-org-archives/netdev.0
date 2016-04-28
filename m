From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip_tunnel: fix preempt warning in ip tunnel
 creation/updating
Date: Thu, 28 Apr 2016 05:09:54 -0700
Message-ID: <1461845394.5535.96.camel@edumazet-glaptop3.roam.corp.google.com>
References: <b21056e2495c485a2084d058d03e1f95480b3510.1461834203.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, tgraf@suug.ch,
	pshelar@nicira.com, jbenc@redhat.com, hannes@stressinduktion.org,
	sergei.shtylyov@cogentembedded.com,
	Tom Herbert <tom@herbertland.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:35739 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbcD1MKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 08:10:04 -0400
Received: by mail-qk0-f177.google.com with SMTP id q76so27377644qke.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 05:10:03 -0700 (PDT)
In-Reply-To: <b21056e2495c485a2084d058d03e1f95480b3510.1461834203.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 11:04 +0200, Paolo Abeni wrote:
> After the commit e09acddf873b ("ip_tunnel: replace dst_cache with generic
> implementation"), a preemption debug warning is triggered on ip4
> tunnels updating; the dst cache helper needs to be invoked in unpreemptible
> context.
> 
> We don't need to load the cache on tunnel update, so this commit fixes
> the warning replacing the load with a dst cache reset, which is
> preempt safe.
> 
> Fixes: e09acddf873b ("ip_tunnel: replace dst_cache with generic
> implementation")
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Seems good to me, thanks.

Note that the Fixes: tag should not be followed by a blank line.
(And presumably no line wrap is necessary)
It really is part of the standard set of tags.
They should be grouped together.

Acked-by: Eric Dumazet <edumazet@google.com>
