From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 18:54:43 -0500
Message-ID: <be7c1d34-038b-a82d-8d0f-ab442f45e104@udel.edu>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
 <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <d8df0fb3-6053-10e1-fc43-cccbfc3799bf@udel.edu>
 <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
 <20170111195909.GL24086@oracle.com>
 <1484167422.15816.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <0d48793d-81f1-3666-5c47-9c2431198dc1@udel.edu>
 <1484171257.15816.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36302 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753169AbdAKXyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 18:54:46 -0500
Received: by mail-qk0-f178.google.com with SMTP id 11so3996990qkl.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 15:54:46 -0800 (PST)
In-Reply-To: <1484171257.15816.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/11/17 4:47 PM, Eric Dumazet wrote:
> On Wed, 2017-01-11 at 16:26 -0500, Jonathan T. Leighton wrote:
>
>> I'm sure I understand what you're saying here. There should be no flow
>> to terminate.

I think you figured out that I meant "I'm not sure I understand...".

>> rfc2765 describes a way to use IPv4-mapped IPv6 packets on the wire.

I don't agree - I didn't read rfc2765 because it's obsolete, but the 
current version does not allow the use of IPv4-mapped IPv6 addresses. 
rfc2765 is obsoleted by rfc6145, and that in turn by rfc7915. rfc7915 
refers to both rfc6052 and rfc6219 for descriptions of the allowable 
mechanisms for translating from IPv4 to IPv6, and the mechanisms in each 
of those documents preclude the use of IPv4-mapped IPv6 addresses 
(::ffff:0:0/96). There's no conflict with rfc6890 (BCP153), which 
explicitly precludes the use of IPv4-mapped IPv6 addresses as a source 
(or destination) address.

> What I meant by 'terminating' was that it does not tell if an end system
> (a host) is allowed to natively generate these packets.
>
> Anyway,
> https://tools.ietf.org/html/draft-itojun-v6ops-v4mapped-harmful-00
>
> (which does not appear to be an RFC), tells us this would be
> dangerous ;)
>
>
>
