From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 0/3] Implement delete for BPF LPM trie
Date: Tue, 19 Sep 2017 17:16:13 -0400
Message-ID: <CAEfhGiybHecYsJ+3eXMFfohh_Jp_yyDfr8ZkydGaQyZJbVQXwA@mail.gmail.com>
References: <20170918193057.37644-1-kraigatgoog@gmail.com> <20170919.135530.717500199880384307.davem@davemloft.net>
 <94373907-6cf5-22af-54e6-7625f31447e0@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:51277 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdISVQQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 17:16:16 -0400
Received: by mail-qk0-f181.google.com with SMTP id c69so944029qke.8
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 14:16:15 -0700 (PDT)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by smtp.gmail.com with ESMTPSA id r11sm190526qkh.80.2017.09.19.14.16.14
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 14:16:14 -0700 (PDT)
Received: by mail-qt0-f180.google.com with SMTP id l25so980340qtf.13
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 14:16:14 -0700 (PDT)
In-Reply-To: <94373907-6cf5-22af-54e6-7625f31447e0@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 5:13 PM, Daniel Mack <daniel@zonque.org> wrote:
> On 09/19/2017 10:55 PM, David Miller wrote:
>> From: Craig Gallek <kraigatgoog@gmail.com>
>> Date: Mon, 18 Sep 2017 15:30:54 -0400
>>
>>> This was previously left as a TODO.  Add the implementation and
>>> extend the test to cover it.
>>
>> Series applied, thanks.
>>
>
> Hmm, I think these patches need some more discussion regarding the IM
> nodes handling, see the reply I sent an hour ago. Could you wait for
> that before pushing your tree?

I can follow up with a patch to implement your suggestion.  It's
really just an efficiency improvement, though, so I think it's ok to
handle independently. (Sorry, I haven't had a chance to play with the
implementation details yet).

Craig
