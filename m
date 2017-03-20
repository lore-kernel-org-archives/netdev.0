From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH nf v2 1/1] netfilter: snmp: Fix one possible panic when
 snmp_trap_helper fail to register
Date: Mon, 20 Mar 2017 18:15:48 +0800
Message-ID: <CA+6hz4pkQR0xvwru2cr8gPgsC6aeEXh+45+82awk_BE5D-mqTQ@mail.gmail.com>
References: <1490003728-33866-1-git-send-email-fgao@ikuai8.com> <02f61fe0-37d9-8837-1c8f-390c5dea6ff4@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>, jolsa@redhat.com,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33217 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753679AbdCTKRp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 06:17:45 -0400
In-Reply-To: <02f61fe0-37d9-8837-1c8f-390c5dea6ff4@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 6:09 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 3/20/2017 12:55 PM, fgao@ikuai8.com wrote:
>
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> In the commit <93557f53e1fb> ("netfilter: nf_conntrack: nf_conntrack snmp
>
>
>    Angle brackets not needed. :-)
>    The commit citing style is the same as for the Fixes: tag.

The checkpatch.pl reports the following error, if remove the angle brackets.

ERROR: Please use git commit description style 'commit <12+ chars of
sha1> ("<title line>")' - ie: 'commit fatal: ambig ("evision or path
not in the working tree.")'
#7:
In the commit 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp

total: 1 errors, 0 warnings, 0 checks, 27 lines checked


Regards
Feng

>
>> helper"), the snmp_helper is replaced by nf_nat_snmp_hook. So the
>> snmp_helper is never registered. But it still tries to unregister the
>> snmp_helper, it could cause the panic.
>>
>> Now remove the useless snmp_helper and the unregister call in the
>> error handler.
>>
>> Fixes: 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp helper")
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>
> [...]
>
> MBR, Sergei
>
