From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 16:26:04 -0500
Message-ID: <0d48793d-81f1-3666-5c47-9c2431198dc1@udel.edu>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
 <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <d8df0fb3-6053-10e1-fc43-cccbfc3799bf@udel.edu>
 <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
 <20170111195909.GL24086@oracle.com>
 <1484167422.15816.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:32955 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758573AbdAKV0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:26:08 -0500
Received: by mail-qt0-f181.google.com with SMTP id v23so694823qtb.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 13:26:07 -0800 (PST)
In-Reply-To: <1484167422.15816.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 1/11/17 3:43 PM, Eric Dumazet wrote:
> On Wed, 2017-01-11 at 14:59 -0500, Sowmini Varadhan wrote:
>
>> I think the RFC states somewhere that you should never ever
>> send out a v4 mapped address on the wire.
> Can you point the exact RFC ?
>
> https://tools.ietf.org/html/rfc2765  seems to allow just that.

Link was in my original post. See table 20:

https://tools.ietf.org/html/rfc6890#page-14

> Jonathan issue is about terminating such flows in TCP stack, which is
> likely not needed/useful.

I'm sure I understand what you're saying here. There should be no flow 
to terminate.

>
>
>
>
