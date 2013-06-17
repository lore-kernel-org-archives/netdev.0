From: Dave Jones <davej@redhat.com>
Subject: Re: [r8169 3.10rc5] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0
 timed out
Date: Mon, 17 Jun 2013 09:42:02 -0400
Message-ID: <20130617134202.GA15861@redhat.com>
References: <20130615184646.GA19439@redhat.com>
 <20130616081533.GA24737@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754001Ab3FQReX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 13:34:23 -0400
Content-Disposition: inline
In-Reply-To: <20130616081533.GA24737@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 16, 2013 at 10:15:33AM +0200, Francois Romieu wrote:
 > Dave Jones <davej@redhat.com> :
 > > I see this from time to time, but this is the first time in a few months since
 > > I last saw it..
 > 
 > I guess the driver did not recover, right ?

actually, it's still up even now.

 > Which chipset ('dmesg | grep XID') is it ?

There's two of them in that box..

[   53.061780] r8169 0000:01:00.0 eth0: RTL8168d/8111d at 0xffffc90000006000, 70:71:bc:63:19:05, XID 081000c0 IRQ 46
[   53.176606] r8169 0000:05:00.0 eth1: RTL8110s at 0xffffc9000003a000, 00:0f:b5:fb:c3:a6, XID 04000000 IRQ 21

but it looks to me like the trace was from eth1

	Dave
