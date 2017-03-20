From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH nf 1/1] netfilter: snmp: Fix one possible panic when
 snmp_trap_helper fail to register
Date: Mon, 20 Mar 2017 17:57:21 +0800
Message-ID: <CA+6hz4qqSnBDFuNQNkBGpaEc1t2o+o6+TDKN4rZWcwjygxcXWA@mail.gmail.com>
References: <1489974248-60293-1-git-send-email-fgao@ikuai8.com> <b2344023-5045-a127-a3f2-0fc7ef898505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, jolsa@redhat.com,
        "David S. Miller" <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36666 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753442AbdCTKZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 06:25:02 -0400
In-Reply-To: <b2344023-5045-a127-a3f2-0fc7ef898505@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 5:37 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello!
>
> On 3/20/2017 4:44 AM, fgao@ikuai8.com wrote:
>
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> In the commit ("netfilter: nf_conntrack: nf_conntrack snmp helper"),
>
>
>    Need to specify the 12-digit SHA1 ID as well.

Thanks Sergei.
I didn't know it is asked to add SHA1 ID into description, thanks your reminder.

I have sent the v2 patch.

Regards
Feng

>
>> the snmp_helper is replaced by nf_nat_snmp_hook. So the snmp_helper
>> is never registered. But it still tries to unregister the snmp_helper,
>> it could cause the panic.
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
