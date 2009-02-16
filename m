From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH] net/mv643xx: don't disable the mib timer too early
Date: Mon, 16 Feb 2009 09:29:22 +0100
Message-ID: <20090216082922.GA18030@Chamillionaire.breakpoint.cc>
References: <20090215092719.GB12280@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:39075 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752778AbZBPI3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 03:29:24 -0500
Content-Disposition: inline
In-Reply-To: <20090215092719.GB12280@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Sebastian Andrzej Siewior | 2009-02-15 10:27:19 [+0100]:

>because mib_counters_update() also restarts the timer.
>So the timer is dequeued, the stats are read and then the timer is
>enqueued again. This is okay, unless someone unloads the module.
I got to NAK that one myself. I make a new one which does not break sth.
else .)

Sebastian
