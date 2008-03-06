From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Treason uncloaked spams syslog with latest git
Date: Thu, 6 Mar 2008 15:31:29 -0800
Message-ID: <20080306153129.e247cd1a.akpm@linux-foundation.org>
References: <alpine.LFD.1.00.0803061140380.3099@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48099 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759361AbYCFXk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:40:58 -0500
In-Reply-To: <alpine.LFD.1.00.0803061140380.3099@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Mar 2008 11:47:12 +0100 (CET)
Thomas Gleixner <tglx@linutronix.de> wrote:

> Since I updated one of my compile boxen to latest git I get the syslog
> flooded with:
> 
> TCP: Treason uncloaked! Peer 192.168.0.1:10245/56637 shrinks window 2748077551:2748080447. Repaired.
> TCP: Treason uncloaked! Peer 192.168.0.68:10245/39915 shrinks window 2890195332:2890201124. Repaired.
> TCP: Treason uncloaked! Peer 192.168.0.65:10245/46058 shrinks window 2880740873:2880745217. Repaired.
> 
> This happens _always_ when I compile kernels with distcc or icecc. All
> systems involved run Linux with kernels >= 2.6.23 and are on the same
> network; no routers, firewalls or other fancy stuff.
> 
> Any idea what's going on here ?
> 

(cc netdev)
