From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: v3.5: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Wed, 1 Aug 2012 21:24:55 +0200
Message-ID: <20120801192455.GA29755@electric-eye.fr.zoreil.com>
References: <20120730190236.30339.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55626 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab2HATiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 15:38:51 -0400
Content-Disposition: inline
In-Reply-To: <20120730190236.30339.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

George Spelvin <linux@horizon.com> :
[...]
> There are a few local patches, but only two are anywhere close to the
> network interface, and they are test patches designed to fix this.
> Should I get rid of them?

It's up to you but I suggest that you keep them until there is something
better.

As long as the device recovers, you may try and lower the watchdog timeout
as well as increase the Tx ring size a bit (x2 or x4) to minimize the
annoyances.

-- 
Ueimor
