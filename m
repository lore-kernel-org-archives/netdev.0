From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 07:30:06 -0800
Message-ID: <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E905C8.1060408@hartkopp.net>
	 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:61439 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaA2PaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 10:30:10 -0500
Received: by mail-pd0-f178.google.com with SMTP id y13so1811859pdi.23
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 07:30:09 -0800 (PST)
In-Reply-To: <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-29 at 07:02 -0800, Eric Dumazet wrote:

> Thats how every protocol does this, with variants.
> 
> Check l2tp_sock_wfree()/l2tp_skb_set_owner_w() for an example

Also keep in mind this patch is needed for all kernels, not only 3.11+

So better keep it as simple as possible, to ease backports.
