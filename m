From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 1/3] tipc: cosmetic: clean up comments
Date: Wed, 01 May 2013 20:18:32 +0400
Message-ID: <51814058.3080805@cogentembedded.com>
References: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com> <1367307199-10577-1-git-send-email-gerlando.falauto@keymile.com>  <517FB0D9.1070404@cogentembedded.com> <5180C64C.2040805@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
	"erik.hugne@ericsson.com" <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"Brunck, Holger" <Holger.Brunck@keymile.com>
To: Gerlando Falauto <gerlando.falauto@keymile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:64919 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab3EAQS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 12:18:59 -0400
Received: by mail-lb0-f174.google.com with SMTP id t11so1600728lbd.19
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 09:18:58 -0700 (PDT)
In-Reply-To: <5180C64C.2040805@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-05-2013 11:37, Gerlando Falauto wrote:

>>> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
>>> ---
>>> Changes from v2:
>>> * Split cosmetic from functional changes

>>>    net/tipc/bcast.c |   13 +++++++------
>>>    1 file changed, 7 insertions(+), 6 deletions(-)

>>> diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
>>> index 2655c9f..8438e01 100644
>>> --- a/net/tipc/bcast.c
>>> +++ b/net/tipc/bcast.c
>>> @@ -584,8 +584,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
>>>    {
>>>        int bp_index;
>>>
>>> -    /*
>>> -     * Prepare broadcast link message for reliable transmission,
>>> +    /* Prepare broadcast link message for reliable transmission,
>>>         * if first time trying to send it;
>>>         * preparation is skipped for broadcast link protocol messages
>>>         * since they are sent in an unreliable manner and don't need it
>>> @@ -613,11 +612,12 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
>>>            struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
>>>
>>>            if (!p)
>>> -            break;    /* no more bearers to try */
>>> +            break; /* No more bearers to try */
>>>
>>> -        tipc_nmap_diff(&bcbearer->remains, &p->nodes,
>>> &bcbearer->remains_new);
>>> +        tipc_nmap_diff(&bcbearer->remains, &p->nodes,
>>> +                   &bcbearer->remains_new);

>>      It apeears you nopt only cleaning up comments in this patch but you don't
>> mention this change in the changelog...

> That's just adding a line break to split a long line.
> Come on, seriously, is that *really* worth mentioning?

    Yes, it is. Otherwise it's an unrelated change.

> How about "tipc: cosmetic: clean up comments and break a long line"?

    Sounds good.

> Thanks,
> Gerlando

WBR, Sergei
