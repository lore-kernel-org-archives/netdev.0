From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 0/1] Add support for tc cookies
Date: Sun, 22 Jan 2017 07:54:26 -0500
Message-ID: <15594a09-5f3a-be5c-530f-316f95157345@mojatatu.com>
References: <1485089498-6673-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35625 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdAVNB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 08:01:59 -0500
Received: by mail-qt0-f195.google.com with SMTP id f4so11313112qte.2
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 05:01:59 -0800 (PST)
In-Reply-To: <1485089498-6673-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I removed people's reviewed/Acked because i changed the data structure
per Daniel's suggestions.

cheers,
jamal
On 17-01-22 07:51 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Changes in V5:
>  - kill the stylistic changes
>  - Adopt a new structure with length-valuepointer representation
>  - rename some things
>
> Changes in v4:
>  - move stylistic changes out into a separate patch
>    (and add more stylistic changes)
>
> Changes in v3:
>  - use TC_ prefix for the max size
>  - move the cookie struct so visible only to kernel
>  - remove unneeded void * cast
>
> Changes in V2:
>  -move from a union to a length-value representation
>
> Jamal Hadi Salim (1):
>   net sched actions: Add support for user cookies
>
>  include/net/act_api.h        |  1 +
>  include/net/pkt_cls.h        |  8 ++++++++
>  include/uapi/linux/pkt_cls.h |  3 +++
>  net/sched/act_api.c          | 35 +++++++++++++++++++++++++++++++++++
>  4 files changed, 47 insertions(+)
>
