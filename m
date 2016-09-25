From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 19:47:45 -0400
Message-ID: <02477255-73b1-1efc-c886-f37507e930f0@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
 <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
 <20160923184030.75124289@halley>
 <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
 <57E7FAC7.6090904@iogearbox.net> <20160925183351.GB3307@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:37894 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941063AbcIYXrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 19:47:49 -0400
Received: by mail-it0-f41.google.com with SMTP id n143so61115442ita.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 16:47:48 -0700 (PDT)
In-Reply-To: <20160925183351.GB3307@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 02:33 PM, Florian Westphal wrote:
> Daniel Borkmann <daniel@iogearbox.net> wrote:
[..]
>>
>> Why not just reuse xmit_recursion, which is what we did in tc cls_bpf
>> programs f.e. see __bpf_tx_skb()? Would be a pity to waste 3 bits on
>> this in the skb.
>
> +1, don't (yet) understand why a per-skb counter is required for this.
>

If you could solve redirecting from ingress->egress with xmit_recursion
then we are set ;->

cheers,
jamal
