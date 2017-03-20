From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH nf v2 1/1] netfilter: snmp: Fix one possible panic when
 snmp_trap_helper fail to register
Date: Mon, 20 Mar 2017 19:35:28 +0300
Message-ID: <4da3e4cf-bcfa-e0fe-539c-4fc03e8959a9@cogentembedded.com>
References: <1490003728-33866-1-git-send-email-fgao@ikuai8.com>
 <02f61fe0-37d9-8837-1c8f-390c5dea6ff4@cogentembedded.com>
 <CA+6hz4pkQR0xvwru2cr8gPgsC6aeEXh+45+82awk_BE5D-mqTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>, jolsa@redhat.com,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:32943 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755403AbdCTQfn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 12:35:43 -0400
Received: by mail-lf0-f46.google.com with SMTP id a6so57729130lfa.0
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 09:35:36 -0700 (PDT)
In-Reply-To: <CA+6hz4pkQR0xvwru2cr8gPgsC6aeEXh+45+82awk_BE5D-mqTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2017 01:15 PM, Feng Gao wrote:

>>> From: Gao Feng <fgao@ikuai8.com>
>>>
>>> In the commit <93557f53e1fb> ("netfilter: nf_conntrack: nf_conntrack snmp
>>
>>
>>    Angle brackets not needed. :-)
>>    The commit citing style is the same as for the Fixes: tag.
>
> The checkpatch.pl reports the following error, if remove the angle brackets.

    Because it stops recognizing the commit ID! :-)

> ERROR: Please use git commit description style 'commit <12+ chars of
> sha1> ("<title line>")' - ie: 'commit fatal: ambig ("evision or path
> not in the working tree.")'

    So check the patch in the correct tree because that seems to be the 
problem... Angle brackets are surely not required.

> #7:
> In the commit 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp
>
> total: 1 errors, 0 warnings, 0 checks, 27 lines checked
>
>
> Regards
> Feng

[...]

MBR, Sergei
