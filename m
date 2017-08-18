From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net v2] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Fri, 18 Aug 2017 13:56:10 -0400
Message-ID: <CAF=yD-+GgSo1MXTT-7ADzs2ktKMQRhiH+0zMg+rwX0BA9+1SDQ@mail.gmail.com>
References: <20170818021157.20070-1-matthew@mjdsystems.ca> <1503065118.3344.18.camel@redhat.com>
 <1789862.HUSStbeWG9@ring00>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Matthew Dawson <matthew@mjdsystems.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34697 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752562AbdHRR4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:56:52 -0400
Received: by mail-oi0-f49.google.com with SMTP id x3so103931953oia.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 10:56:51 -0700 (PDT)
In-Reply-To: <1789862.HUSStbeWG9@ring00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > +   if (flags & MSG_PEEK && *off >= 0) {
>> > +           peek_at_off = true;
>> > +           _off = *off;
>> > +   }
>>
>> I think that unlikely() will fit the above condition
> Sounds good.

Doesn't the compiler implicitly mark branches as unlikely if they
do not have an else clause?
