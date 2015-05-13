From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next v3] net: core: set qdisc pkt len before tc_classify
Date: Wed, 13 May 2015 16:54:37 -0700
Message-ID: <20150513235436.GA4851@Alexeis-MacBook-Pro.local>
References: <1431556588-4859-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35686 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbbEMXyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 19:54:40 -0400
Received: by pdbqd1 with SMTP id qd1so66379759pdb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 16:54:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431556588-4859-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 12:36:28AM +0200, Florian Westphal wrote:
> commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
> removed the call to qdisc_enqueue_root().
> 
> However, after this removal we no longer set qdisc pkt length.
> This breaks traffic policing on ingress.
> 
> This is the minimum fix: set qdisc pkt length before tc_classify.

Thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
