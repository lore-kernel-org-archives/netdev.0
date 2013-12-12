From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Thu, 12 Dec 2013 13:11:05 -0800
Message-ID: <1386882665.19078.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
	 <1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131212.135433.87781160683841713.davem@davemloft.net>
	 <CA+mtBx9GNG3XuyczBAJT4o2FnRBbHTV5U6PYnAJA1gf84ExeNQ@mail.gmail.com>
	 <1386880196.19078.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-hCve-NXDkQLv0bVrrESLOKPH17nzbhMAPORweFr11Og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:57628 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab3LLVLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 16:11:09 -0500
Received: by mail-yh0-f50.google.com with SMTP id b6so851694yha.37
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 13:11:08 -0800 (PST)
In-Reply-To: <CA+mtBx-hCve-NXDkQLv0bVrrESLOKPH17nzbhMAPORweFr11Og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 12:56 -0800, Tom Herbert wrote:

> Reverting that patch doesn't fix the problem. We are hitting the
> spinlock in gro_cells_receive a lot though.

Well, something broke then.

I was able to reach line rate at the time I did this work.
