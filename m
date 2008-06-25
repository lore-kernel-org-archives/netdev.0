From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash,
	Another Problem)
Date: Wed, 25 Jun 2008 23:31:42 +0200
Message-ID: <20080625213142.GA29890@electric-eye.fr.zoreil.com>
References: <4861800B.90703@nscus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michael Grollman <mgrollman@nscus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41741 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752499AbYFYVbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 17:31:48 -0400
Content-Disposition: inline
In-Reply-To: <4861800B.90703@nscus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Grollman <mgrollman@nscus.com> :
> <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

No html please.

[...]
> Patch of <a class="moz-txt-link-freetext" href="http://lkml.org/lkml/2008/4/17/298">http://lkml.org/lkml/2008/4/17/298</a> seems to fix the boot-up
> modprobe crash related to r8169 Intermittent Issue With RTL8102E
> Chipset in Intel's New D945GCLF Atom Board.&nbsp; However, the r8169 still
> only seems to work with this motherboard / realtek combo a certain
> percentage of the time.&nbsp; I have found the best luck when unplugging the
> power supply for 5 minutes, and then bring it up cold, thought his was
> also not perfect.&nbsp; Warm boots, then r8169 driver will load, but not
> work correctly all the time.<br>

Can you simply check with the latest -rc that 'lspci -vx' correctly displays
the pci registers of the 8102 when the device does not work ?

-- 
Ueimor
