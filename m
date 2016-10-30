From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Let's do P4
Date: Sun, 30 Oct 2016 13:54:58 -0700
Message-ID: <58165E22.4020704@gmail.com>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com> <20161030074458.GB1686@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
        davem@davemloft.net, tgraf@suug.ch, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32791 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbcJ3Uz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 16:55:28 -0400
Received: by mail-pf0-f194.google.com with SMTP id a136so3460446pfa.0
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 13:55:28 -0700 (PDT)
In-Reply-To: <20161030074458.GB1686@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> 
> Yeah, I was also thinking about something similar to your Flow-API,
> but we need something more generic I believe.

I've heard this in a couple other forums as well but please elaborate
exactly what needs to be more generic? That API is sufficient to both
express the init time piece of the original P4 draft and the runtime
component.

I guess we are trying to strike a balance here between the ability
to actually write an IR that a sufficiently large subset of hardware
can support "easily" and something that can support all possible
hardware features.

IMO this leads to something like the Flow-API in the first case or
to something like eBPF for all possible features.

> 
> 
>>
>> We also have an emulated path also auto-generated from compiler tools
>> that creates eBPF code from the IR so this would give you the software
>> fall-back.
> 
> 
> Btw, Flow-API was rejected because it was a clean kernel-bypass. In case
> of p4, if we do what Thomas is suggesting, having x.bpf for SW and
> x.p4ast for HW, that would be the very same kernel-bypass. Therefore I
> strongly believe there should be a single kernel API for p4 SW+HW - for
> both p4 program insertion and runtime configuration.

Another area of push-back came from creating yet another infrastructure.
