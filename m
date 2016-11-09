From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/2] tcp: tcp_get_info() locking changes
Date: Wed, 09 Nov 2016 10:58:41 -0800
Message-ID: <1478717921.16809.0.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478285672-3195-1-git-send-email-edumazet@google.com>
         <20161109.130319.505221196913812307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
        ycheng@google.com, soheil@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35803 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbcKIS6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:58:43 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so1174428pfk.2
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 10:58:42 -0800 (PST)
In-Reply-To: <20161109.130319.505221196913812307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-09 at 13:03 -0500, David Miller wrote:

> Looks really nice, series applied, thanks Eric.
> 
> BTW, can we possibly use the netlink NOP trick to align the netlink
> attribute data here and avoid these unaligned accesses?
> 

Good idea, I will do this, thanks for the suggestion.
