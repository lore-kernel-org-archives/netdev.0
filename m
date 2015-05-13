From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v3] net: core: set qdisc pkt len before tc_classify
Date: Wed, 13 May 2015 15:49:53 -0700
Message-ID: <1431557393.27831.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431556588-4859-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34286 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965440AbbEMWtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 18:49:55 -0400
Received: by iecmd7 with SMTP id md7so45893852iec.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 15:49:54 -0700 (PDT)
In-Reply-To: <1431556588-4859-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 00:36 +0200, Florian Westphal wrote:
> commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
> removed the call to qdisc_enqueue_root().
> 
> However, after this removal we no longer set qdisc pkt length.
> This breaks traffic policing on ingress.
> 
> This is the minimum fix: set qdisc pkt length before tc_classify.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
