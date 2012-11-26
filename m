From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: BQL support in gianfar causes network hickup
Date: Mon, 26 Nov 2012 11:01:11 +0100
Message-ID: <20121126100111.GA3728@mac.home>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
 <50AFA599.9040108@windriver.com>
 <loom.20121124T213422-650@post.gmane.org>
 <1353800616.2590.4562.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:49578 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238Ab2KZKLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 05:11:39 -0500
Received: from mac.home (mnch-5d86e656.pool.mediaWays.net [93.134.230.86])
	by eazy.amigager.de (Postfix) with ESMTPA id 9BABBC8C6D0
	for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 11:01:13 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1353800616.2590.4562.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 24, 2012 at 15:43:36 -0800, Eric Dumazet wrote:

[...]

> Hmm, I wonder if BQL makes a particular bug showing more often.
> 
> I see gianfar uses a very small watchdog_timeo of 1 second, while many
> drivers use 5 seconds.
> 
> What happens if you change this to 5 seconds ?

I still got the trace and a failing ptp client.

Regards,
Tino
