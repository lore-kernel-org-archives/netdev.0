From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] tcp: plug dst leak in tcp_v6_conn_request()
Date: Mon, 25 Jun 2012 08:35:25 +0200
Message-ID: <1340606125.10893.4.camel@edumazet-glaptop>
References: <1340515324-2152-1-git-send-email-ncardwell@google.com>
	 <1340515324-2152-5-git-send-email-ncardwell@google.com>
	 <1340523678.23933.11.camel@edumazet-glaptop>
	 <CADVnQykuAQcj_i5cZQphKnnoHaCPMd6xLBmq1ZSAeZs83z3tfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57608 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab2FYGft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:35:49 -0400
Received: by bkcji2 with SMTP id ji2so2817988bkc.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 23:35:48 -0700 (PDT)
In-Reply-To: <CADVnQykuAQcj_i5cZQphKnnoHaCPMd6xLBmq1ZSAeZs83z3tfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-24 at 13:12 -0400, Neal Cardwell wrote:
>  http://patchwork.ozlabs.org/patch/166737/
> 
> Yes, the patches in this series were generated as patches against the
> "net" tree (sorry for not indicating that).
> 
> The dst leak on the v6 sysctl_tw_recycle code path (patches 2-5) seems
> like a pretty low priority, so I think we could simplify your plan
> even a little further... How about this as a plan: we could apply the
> first patch in the series (tcp: heed result of
> security_inet_conn_request() in tcp_v6_conn_request()) to the net tree
> now, and skip patches 2-5 for now. Once your pending synack work is in
> net-next, I can respin patches 2-5 for net-next. How does that sound?
> 

It sounds good, thanks !
