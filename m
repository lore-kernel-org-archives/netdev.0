From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix ineffective source address selection
Date: Fri, 04 Oct 2013 08:49:18 -0700
Message-ID: <1380901758.3564.14.camel@edumazet-glaptop.roam.corp.google.com>
References: <245895a0777442b56ecea1453be041aa1b31c5a2.1380898983.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:56232 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691Ab3JDPtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 11:49:20 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so4170086pbb.34
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 08:49:19 -0700 (PDT)
In-Reply-To: <245895a0777442b56ecea1453be041aa1b31c5a2.1380898983.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-04 at 17:04 +0200, Jiri Benc wrote:
> When sending out multicast messages, the source address in inet->mc_addr is
> ignored and rewritten by an autoselected one. This is caused by a typo in
> commit 813b3b5db831 ("ipv4: Use caller's on-stack flowi as-is in output
> route lookups").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---

Nice catch !

Acked-by: Eric Dumazet <edumazet@google.com>
