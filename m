From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 15 May 2012 17:29:24 +0100
Message-ID: <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10641 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965661Ab2EOQ33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 12:29:29 -0400
In-Reply-To: <1337093776.8512.1089.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 16:56 +0200, Eric Dumazet wrote:
> 
> Please try latest kernels, this is probably 'fixed'

I've just tried with 3.4.0-rc7 and the problem is still reproducible.
It's perhaps harder to reproduce than on 3.3.6 but still there.

> What network driver are you using ? 

The receiver is using the sfc driver that is included in the kernel
build, together with an SFC 9020 NIC. 

Kieran
