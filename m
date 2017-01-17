From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fq_codel and skb->hash
Date: Mon, 16 Jan 2017 18:34:40 -0800
Message-ID: <1484620480.13165.65.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
         <1484617489.13165.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Andrew Collins <acollins@cradlepoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34343 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdAQClN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 21:41:13 -0500
Received: by mail-pg0-f68.google.com with SMTP id t6so2567686pgt.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 18:41:12 -0800 (PST)
In-Reply-To: <1484617489.13165.63.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-16 at 17:44 -0800, Eric Dumazet wrote:
> On Mon, 2017-01-16 at 17:04 -0700, Andrew Collins wrote:

> >   Is there a better way to manage flow separation in routed+encapsulated traffic?
> 
> Encapsulated traffic is fine, since flow dissector skips encap header(s)
> up to the L4 header.
> 
> Problem is about encrypted traffic, since presumably this L4 header is
> opaque for flow dissector ;)


BTW, how can we make sure skb->hash is populated before IPSEC ?

Relying on forwarding, and skb->hash set by a device might be not
enough.
