From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 13:47:37 -0800
Message-ID: <1484171257.15816.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
         <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
         <d8df0fb3-6053-10e1-fc43-cccbfc3799bf@udel.edu>
         <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
         <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
         <20170111195909.GL24086@oracle.com>
         <1484167422.15816.1.camel@edumazet-glaptop3.roam.corp.google.com>
         <0d48793d-81f1-3666-5c47-9c2431198dc1@udel.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: "Jonathan T. Leighton" <jtleight@udel.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36119 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752103AbdAKVrj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:47:39 -0500
Received: by mail-pf0-f194.google.com with SMTP id b22so108651pfd.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 13:47:39 -0800 (PST)
In-Reply-To: <0d48793d-81f1-3666-5c47-9c2431198dc1@udel.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-11 at 16:26 -0500, Jonathan T. Leighton wrote:

> I'm sure I understand what you're saying here. There should be no flow 
> to terminate.

rfc2765 describes a way to use IPv4-mapped IPv6 packets on the wire.

What I meant by 'terminating' was that it does not tell if an end system
(a host) is allowed to natively generate these packets.

Anyway,
https://tools.ietf.org/html/draft-itojun-v6ops-v4mapped-harmful-00 

(which does not appear to be an RFC), tells us this would be
dangerous ;)
