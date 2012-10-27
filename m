From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Information about napi_struct and net_device
Date: Sun, 28 Oct 2012 01:02:23 +0200
Message-ID: <1351378943.30380.332.camel@edumazet-glaptop>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
	 <1351357421.30380.328.camel@edumazet-glaptop>
	 <20121027182207.GA12858@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Javier Domingo <javierdo1@gmail.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48230 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab2J0XC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 19:02:28 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1556678eek.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 16:02:27 -0700 (PDT)
In-Reply-To: <20121027182207.GA12858@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-27 at 20:22 +0200, Francois Romieu wrote:

> Not all drivers use napi_gro_receive/napi_gro_flush.
> 

Yes, note that I only mentioned "grep napi", not these specific verbs

Also, napi_gro_receive() could be used now GRO doesnt mandate hardware
checksums.

> It could be worth comparing with drivers/net/ethernet/via/via-rhine.c (small)
> or drivers/net/ethernet/broadcom/tg3.c (bigger).

Unfortunately tg3.c uses internal stuff sith napi substring, so I
ignored it :

$ grep napi drivers/net/ethernet/broadcom/tg3.c | wc -l
376
