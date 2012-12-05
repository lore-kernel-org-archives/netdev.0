From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed out
Date: Wed, 5 Dec 2012 23:47:51 +0100
Message-ID: <20121205224751.GA21295@electric-eye.fr.zoreil.com>
References: <20121205011910.GA16531@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45061 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604Ab2LEXNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 18:13:00 -0500
Content-Disposition: inline
In-Reply-To: <20121205011910.GA16531@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> :
> Mezigues : 
> > Dave Jones <davej@redhat.com> :
> > [...]
> > > Anything else I can provide ?
> > Please send the XID of the device.
> 
> [   55.576012] r8169 0000:01:00.0 eth0: RTL8168d/8111d at 0xffffc9000037a000, 70:71:bc:63:19:05, XID 081000c0 IRQ 46
> [   55.805446] r8169 0000:05:00.0 eth1: RTL8110s at 0xffffc9000037e000, 00:0f:b5:fb:c3:a6, XID 04000000 IRQ 21
> 
> The one that seems to be complaining is the 2nd one.

I'll plug one and see if it went more touchy than usual. 

I do not see anything obvious at first sight. Reverting
aee77e4accbeb2c86b1d294cd84fec4a12dde3bd maybe.

-- 
Ueimor
