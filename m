From: Dieter Ries <clip3@gmx.de>
Subject: Re: Current Git: BUG: unable to handle kernel paging request at 0000000001a40ca0
Date: Wed, 23 Jul 2008 23:53:36 +0200
Message-ID: <4887A860.6070607@gmx.de>
References: <488750AA.20707@gmx.de> <19f34abd0807231046o4b194409w7d0e28a7cd745afa@mail.gmail.com> <48877200.9040608@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>,
	jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp1.ethz.ch ([82.130.70.13]:2187 "EHLO xsmtp1.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768AbYGWVxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 17:53:38 -0400
In-Reply-To: <48877200.9040608@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dieter Ries schrieb:
> Vegard Nossum schrieb:
>> Hi,
> 
Hi

>> Dieter: If this is reproducible, it would probably help quite a bit to
>> configure the kernel with CONFIG_SLUB_DEBUG and boot with
>> slub_debug=FZPUT (unless you already have CONFIG_SLUB_DEBUG_ON set, in
>> which case you are already running with the SLUB debugging at boot).
>> It might catch the corruption before it becomes fatal, or give us some
>> more clues anyway.

I tried to bisect the bug, which failed because there were too many 
kernels not booting with other problems, I guess bisecting just fails in 
the merge window.

With CONFIG_SLUB_DEBUG_ON the output looks different, unfortunately 
netconsole stops before those are transmitted.

As there are always some lines about e1000 in the backtraces, I tried to 
boot without LAN cable connected, and it worked, and crashed afterwards 
when I plugged the cable in, with a bug in net/core/dev.c.

I will search on tomorrow, as it is getting quite late now.

Should I copy the messages with CONFIG_SLUB_DEBUG_ON by hand, or are 
just some parts important?

cu
Dieter
