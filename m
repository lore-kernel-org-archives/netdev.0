From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: basic question about LRO implementation
Date: Tue, 22 Apr 2014 06:54:10 -0700
Message-ID: <1398174850.29946.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJ3bTp5v5jbpfnc78YXXEbYxOYpWnkz7UioznwszrvqcuHjD=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:43114 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756020AbaDVNyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 09:54:11 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so553341pde.12
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 06:54:11 -0700 (PDT)
In-Reply-To: <CAJ3bTp5v5jbpfnc78YXXEbYxOYpWnkz7UioznwszrvqcuHjD=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-22 at 13:28 +0530, Rayagond Kokatanur wrote:
> Hi All,
> 
> As part of LRO support, every Ethernet driver has to implement a call
> back function ".get_skb_header" which does following,
> 
> 1. Checks for TCP packet and return 0 for TCP packet and -1 for non-tcp packets
> 2. Get tcp and ip header from given skb
> 3. Initialize the flag to indicate IPv4 and  TCP packet.
> 
> All these can be done by using skb - which is passed as input argument
> to get_skb_header, there is nothing device specific we do in this api,
> hence why can't this be implemented as generic api. By this way we can
> avoid every driver implementing same api and hence duplicating the
> same code.
> 
> Please let me know if my understanding may be wrong.

LRO is deprecated.

Use GRO, even if hardware assisted like bnx2x driver ?
