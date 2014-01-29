From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Wed, 29 Jan 2014 06:53:45 -0800
Message-ID: <1391007225.28432.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E833ED.4080006@hartkopp.net>
		<1390953066.28432.26.camel@edumazet-glaptop2.roam.corp.google.com>
		<52E8B053.2030808@gmail.com>
	 <20140128.234630.1768378245126172951.davem@davemloft.net>
	 <52E8C03A.4030906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Andre Naujoks <nautsch2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:34680 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbaA2Oxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 09:53:46 -0500
Received: by mail-pb0-f53.google.com with SMTP id md12so1833727pbc.40
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 06:53:46 -0800 (PST)
In-Reply-To: <52E8C03A.4030906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-29 at 09:47 +0100, Andre Naujoks wrote:
> On 29.01.2014 08:46, schrieb David Miller:
> > From: Andre Naujoks <nautsch2@gmail.com>
> > Date: Wed, 29 Jan 2014 08:40:03 +0100
> > 
> >> Even if this is a bug in the CAN BCM implementation. Your "fix" just
> >> enabled a user space application to shut down any machine with a kernel
> >> containing the BUG_ON patch.
> > 
> > Rather, he detected a potential stray pointer reference to freed data
> > that was caused by the CAN code which would difficult if not
> > impossible to detect otherwise.
> > 
> > That's even more dangerous, and you should be thanking him.
> 
> "potential" is the keyword here. But its a definite kernel crash as it
> is right now with a standard use case for the BCM.
> 
> Don't get me wrong. If there are bugs in the code, they should be fixed,
> but I don't think breaking a working (even if flawed) part of the kernel
> is the right thing to do here.

Shall I remember you this patch was suggested by David Miller, our
beloved network maintainer ?

Really this is quite silly, I'll tell you.

I can send a patch to mark CAN as BROKEN if you want, or you can send an
appropriate patch.

Your resistance is futile.
