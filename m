From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: loopback: fix a dst refcounting issue
Date: Sun, 27 Jan 2013 09:25:08 -0800
Message-ID: <1359307508.5222.2226.camel@edumazet-glaptop>
References: <1358989843.12374.1334.camel@edumazet-glaptop>
	 <1358991906.12374.1356.camel@edumazet-glaptop>
	 <1359135881.12374.3249.camel@edumazet-glaptop>
	 <20130127.013241.1524448507498580112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:65209 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab3A0RZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 12:25:11 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so1086273pad.12
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 09:25:10 -0800 (PST)
In-Reply-To: <20130127.013241.1524448507498580112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-27 at 01:32 -0500, David Miller wrote:

> Applied, I suspect we need to tree wide audit for other instances of
> this situation.  Probably greps for skb_orphan() would be a good
> start.

I highly suspect macvlan needs a skb_dst_drop(), but couldnt trigger
a case to trigger the fault.
