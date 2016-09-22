From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Thu, 22 Sep 2016 21:27:45 +0300
Message-ID: <20160922212745.789734c5@halley>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
        <1474556053.23058.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35775 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965944AbcIVS1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 14:27:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id 133so15467449wmq.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 11:27:51 -0700 (PDT)
In-Reply-To: <1474556053.23058.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Sep 2016 07:54:13 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Hmm... we probably need to apply the full rcu protection before this
> patch.
> 
> https://patchwork.ozlabs.org/patch/667680/

Are you referring to order of application into net-next?

This patch seems to present no new tcf_mirred_params members nor
need-to-be-protected code regions (please, correct me if wrong).
So it does not _depend_ on the 'full rcu fixes', does it?

Thanks,
Shmulik
