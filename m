From: Roger Luethi <rl@hellgate.ch>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Sun, 30 Nov 2008 09:58:20 +0100
Message-ID: <20081130085820.GA13944@core.hellgate.ch>
References: <492DD792.6080302@linux.intel.com> <20081128111827.79b12739@osprey.hogchain.net> <20081128093217.3888fb46@linux.intel.com> <20081128195018.GA19538@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Jay Cliburn <jcliburn@gmail.com>,
	NetDev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail11.bluewin.ch ([195.186.18.61]:18388 "EHLO
	mail11.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbYK3JF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 04:05:26 -0500
Content-Disposition: inline
In-Reply-To: <20081128195018.GA19538@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Nov 2008 20:50:18 +0100, Francois Romieu wrote:
> Arjan van de Ven <arjan@linux.intel.com> :
> [...]
> > For me, sis900 and r8169 stand out; if you look at the data in the
> > table above, both of these are an order of magnitude more frequent than
> > the rest of the pack.
> 
> via-rhine + via_rhine = 438: it does not look too good either.

Agreed. I was kinda hoping I'd get some clues for free when other drivers
get fixed :-).

> Is there an (ideally automated) way to retrieve more information ?
> 
> The r8169 driver handles three different chipsets and a plethora of
> phys. The "XID" line printed by the driver could hint at some specific
> PHY for instance.

For the Rhine, knowing the PCI rev would help identify problems tied to
specific models.

Roger
