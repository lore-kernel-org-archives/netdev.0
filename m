From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/arp: ARP cache aging failed.
Date: Wed, 23 Nov 2016 15:49:27 -0800
Message-ID: <1479944967.8455.516.camel@edumazet-glaptop3.roam.corp.google.com>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
         <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
         <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com>
         <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, yuehaibing <yuehaibing@huawei.com>,
        davem@davemloft.net, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35797 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933483AbcKWXt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 18:49:29 -0500
Received: by mail-pg0-f50.google.com with SMTP id p66so11205283pga.2
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 15:49:29 -0800 (PST)
In-Reply-To: <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-23 at 15:37 +0100, Hannes Frederic Sowa wrote:

> Irregardless about the question if bonding should keep the MAC address
> alive, a MAC address can certainly change below a TCP connection.

Of course ;)

> 
> dst_entry is 1:n to neigh_entry and as such we can end up confirming an
> aging neighbor while sending a reply with dst->pending_confirm set while
> the confirming packet actually came from a different neighbor.
> 
> I agree with Julian, pending_confirm became useless in this way.

Let's kill it then ;)
