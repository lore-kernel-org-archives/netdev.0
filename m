From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/4] net/sched: act_mirred: Implement
 ingress actions
Date: Tue, 27 Sep 2016 15:32:29 -0700
Message-ID: <1475015549.28155.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475009975-30332-1-git-send-email-shmulik.ladkani@gmail.com>
         <1475009975-30332-5-git-send-email-shmulik.ladkani@gmail.com>
         <1475011633.28155.68.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160928004244.6b362f56@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34097 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753049AbcI0Wcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 18:32:32 -0400
Received: by mail-pa0-f54.google.com with SMTP id gp7so9750638pac.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 15:32:32 -0700 (PDT)
In-Reply-To: <20160928004244.6b362f56@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-28 at 00:42 +0300, Shmulik Ladkani wrote:

> Thanks Eric.
> 
> I assume adding a READ_ONCE(m->tcfm_eaction) at beggining of section,
> and using the read value, will solve this specific inconsistency?

Sure, adding a READ_ONCE() might work, if done properly ;)
