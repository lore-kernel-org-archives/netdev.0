From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next rfc 0/6] convert tc_verd to integer bitfields
Date: Fri, 30 Dec 2016 19:02:04 -0500
Message-ID: <CAF=yD-KJDmiFt8c+xpEd=WfAN5A=sB9AGo6hjoUwJg4WQ6=-DQ@mail.gmail.com>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <20161229.222113.146921294105321953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>, dborkman@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:32792 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752361AbcLaACp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 19:02:45 -0500
Received: by mail-ua0-f194.google.com with SMTP id d5so18805860uag.0
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 16:02:45 -0800 (PST)
In-Reply-To: <20161229.222113.146921294105321953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 29, 2016 at 10:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Wed, 28 Dec 2016 14:13:24 -0500
>
>> The skb tc_verd field takes up two bytes but uses far fewer bits.
>> Convert the remaining use cases to bitfields that fit in existing
>> holes (depending on config options) and potentially save the two
>> bytes in struct sk_buff.
>
> I like the looks of this, for sure :-)

Great, thanks. I sent it as RFC initially, because there were some unresolved
issues with TC_FROM semantics last time around. bpf_redirect has been
merged in the meantime, so I suspect that that has been resolved.

But there is no rush. I will run a few more tests, such as the new mirred
ingress path, and will hold off resubmitting until people now on holiday
have a chance to chime in next week.
