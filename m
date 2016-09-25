From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Sun, 25 Sep 2016 07:32:42 -0400
Message-ID: <9a0384e6-f3ec-1f43-0e1a-b0da30f3a7a5@mojatatu.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
 <20160923150040.0e3dc7d5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org, kernel-team@fb.com, tariqt@mellanox.com,
        bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, Thomas Graf <tgraf@suug.ch>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36484 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965662AbcIYLco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 07:32:44 -0400
Received: by mail-io0-f194.google.com with SMTP id z135so9600760ioe.3
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 04:32:44 -0700 (PDT)
In-Reply-To: <20160923150040.0e3dc7d5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-23 09:00 AM, Jesper Dangaard Brouer wrote:
> On Fri, 23 Sep 2016 07:13:30 -0400
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>

[..]

>> Tom,
>> perused the thread and it seems you are serious ;->
>> Are we heading towards Frankenstein Avenue?
>> The whole point behind letting in XDP is so that _small programs_
>> can be written to do some quick thing. eBPF 4K program limit was
>> touted as the check and bound. eBPF sounded fine.
>> This sounds like a huge contradiction.
>>
>> cheers,
>> jamal
>
> Hi Jamal,
>
> I don't understand why you think this is so controversial. The way I
> see it (after reading the thread): This is about allowing kernel
> components to _also_ use the XDP hook.
>

The initial push was XDP to support very small programs that did
very simple things fast (to be extreme: for example running a whole
network stack is a no-no). EBPF with the 4K program limit was pointed
as the limit.
What Tom is presenting is implying this constraint is now being
removed. Thats the controversy.

cheers,
jamal
