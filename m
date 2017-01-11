From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 12:43:42 -0800
Message-ID: <1484167422.15816.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
         <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
         <d8df0fb3-6053-10e1-fc43-cccbfc3799bf@udel.edu>
         <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
         <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
         <20170111195909.GL24086@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Jonathan T. Leighton" <jtleight@udel.edu>, netdev@vger.kernel.org,
        edumazet@google.com, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36052 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755311AbdAKUnw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 15:43:52 -0500
Received: by mail-pf0-f193.google.com with SMTP id b22so17166480pfd.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 12:43:49 -0800 (PST)
In-Reply-To: <20170111195909.GL24086@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-11 at 14:59 -0500, Sowmini Varadhan wrote:

> I think the RFC states somewhere that you should never ever
> send out a v4 mapped address on the wire.

Can you point the exact RFC ?

https://tools.ietf.org/html/rfc2765  seems to allow just that.


Jonathan issue is about terminating such flows in TCP stack, which is
likely not needed/useful.
