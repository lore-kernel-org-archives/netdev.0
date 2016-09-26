From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Mon, 26 Sep 2016 17:53:57 +0200
Message-ID: <57E94495.3050306@iogearbox.net>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com> <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com> <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com> <20160923081106.73fb48df@halley> <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com> <20160923184030.75124289@halley> <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com> <20160925203309.633cf3d5@halley> <20160925183136.GA3307@breakpoint.cc> <54535aa0-cafd-86ec-1f6c-64c974a5eed6@mojatatu.com> <20160926013504.GA1959@breakpoint.cc> <54aa5404-f4c8-03e1-0b62-8c070bd6d65b@stressinduktion.org> <57E9366D.6020906@iogearbox.net> <c8d67662-1eaf-7f7e-5a99-17ec0a4521f7@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33851 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750754AbcIZPyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 11:54:06 -0400
In-Reply-To: <c8d67662-1eaf-7f7e-5a99-17ec0a4521f7@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2016 05:12 PM, Hannes Frederic Sowa wrote:
[...]
> I would just care that we sometimes reschedule and don't do everything
> in one stack so we don't corrupt the machine and an admin has still a
> chance to solve the problem.

Sounds reasonable to me, and which is what dev_forward_skb() is doing
implicitly as well.
