From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual device
Date: Fri, 19 Sep 2014 15:14:21 -0700
Message-ID: <CAHA+R7M-HKbCmX3kEPLGrNjh+qF-OnL+V8C2biFBz24_7VOsxw@mail.gmail.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
	<1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M=Wp1u1hXD9YE52Ct74KOovEaVjCECV_5EsrAO_rJ7ag@mail.gmail.com>
	<1411164317.26859.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:63689 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757837AbaISWOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:14:23 -0400
Received: by mail-lb0-f171.google.com with SMTP id l4so3955357lbv.2
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:14:22 -0700 (PDT)
In-Reply-To: <1411164317.26859.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 3:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-09-19 at 14:59 -0700, Cong Wang wrote:
>
>>
>> Then fix these tx_queue_len = 0?
>
> What are you suggesting exactly ?

Quote:
">
 >>
 >> I am not saying using this tx_queue_len is absolutely correct,
 >> I am saying it may be expected to set tx_queue_len by yourself.
 >
 > I disagree.
 >"

So you disagree with setting tx_queue_len manually, then it means
you think every tx_queue_len should have a non-zero value, therefore
those tx_queue_len = 0 should be fixed?

>
> We want them being 0, exactly.


Conflicts with what you claimed by "I disagree." :)
