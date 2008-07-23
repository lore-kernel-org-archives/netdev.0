From: Dieter Ries <clip3@gmx.de>
Subject: Re: Current Git: BUG: unable to handle kernel paging request at 0000000001a40ca0
Date: Wed, 23 Jul 2008 20:01:36 +0200
Message-ID: <48877200.9040608@gmx.de>
References: <488750AA.20707@gmx.de> <19f34abd0807231046o4b194409w7d0e28a7cd745afa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp0.ethz.ch ([82.130.70.14]:3660 "EHLO XSMTP0.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbYGWSQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 14:16:52 -0400
In-Reply-To: <19f34abd0807231046o4b194409w7d0e28a7cd745afa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vegard Nossum schrieb:
> Hi,

Hi,

> 
> Dieter: If this is reproducible, it would probably help quite a bit to
> configure the kernel with CONFIG_SLUB_DEBUG and boot with
> slub_debug=FZPUT (unless you already have CONFIG_SLUB_DEBUG_ON set, in
> which case you are already running with the SLUB debugging at boot).
> It might catch the corruption before it becomes fatal, or give us some
> more clues anyway.
> 

I am bisecting the bug right now, as it is kind of reproducible. Its 
always network related, sometimes it happens when init brings up the 
nics, sometimes afterwards with ifconfig etc.

I will add CONFIG_SLUB_DEBUG_ON for the next runs, next time it happens 
I will post the output.

> 
> Vegard
> 
cu
Dieter
