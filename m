From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH] net: filter: add insn for loading internal transport
 header offset
Date: Thu, 1 May 2014 11:44:39 -0700
Message-ID: <CA+ZOOTPm+--PMjvezym-fxY5cD2Q9EDUMgrAm1JohRVqU0z3pA@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<536227C1.20309@redhat.com>
	<5362281B.3020802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:65097 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbaEASok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 14:44:40 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so845748igd.16
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 11:44:39 -0700 (PDT)
In-Reply-To: <5362281B.3020802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 1, 2014 at 3:55 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> [ Chema, please also keep me in cc if possible. ]
Done.

>> Looks good to me. For casting pointers as Dave noted recently, please
>> use 'unsigned long'. This needs to be fixed in other places as well.
Done.

> Ohh, and please in future include net or net-next into your subject line.
Done.

On Wed, Apr 30, 2014 at 3:21 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> +static u64 __skb_get_tra_offset(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
>> +{
>> +       struct flow_keys keys;
>> +       struct sk_buff *skb = (struct sk_buff *)(long) ctx;
>
> I think kernel style recommends to swap above two lines,
> but that's a nit.
Done.

-Chema
