From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.28: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed
	out
Date: Thu, 15 Jan 2009 21:21:04 +0100
Message-ID: <20090115202104.GA32495@electric-eye.fr.zoreil.com>
References: <alpine.DEB.1.10.0901131617550.6193@p34.internal.lan> <20090114213618.a610d647.akpm@linux-foundation.org> <alpine.DEB.1.10.0901150407130.6755@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Alan Piszcz <ap@solarrain.com>,
	netdev@vger.kernel.org
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46498 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932945AbZAOUUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 15:20:40 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0901150407130.6755@p34.internal.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Justin Piszcz <jpiszcz@lucidpixels.com> :
[...]
> It is the first time I have ever seen it on this system, while running  
> 2.6.28.  I have never seen the error in the past (at least not that I can 
> remember/no log entries) for 2.6.27 or below.

Does it translate into a temporary network hiccup, say a few seconds,
or does it mean a final loss of networking ?

Given the timestamp, the driver seemed to worked for some amount of time
before breaking, did it not ? It would thus be different from the usual
"no link at startup" problem.

Can you send a complete dmesg, including the r8169 XID line ?

-- 
Ueimor
