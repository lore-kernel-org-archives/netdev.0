From: Thomas Graf <tgraf@infradead.org>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 18:35:50 -0500
Message-ID: <20101109233550.GD11005@canuck.infradead.org>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
 <4CD6DF37.6010800@trash.net>
 <20101108151635.GA20629@canuck.infradead.org>
 <4CD91406.4000603@trash.net>
 <20101109144941.GA4018@canuck.infradead.org>
 <alpine.LNX.2.01.1011092113420.10710@obet.zrqbmnf.qr>
 <20101109214039.GA11005@canuck.infradead.org>
 <alpine.LNX.2.01.1011092302070.28314@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:45417 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106Ab0KIXf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 18:35:59 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1011092302070.28314@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 11:02:30PM +0100, Jan Engelhardt wrote:
> 
> On Tuesday 2010-11-09 22:40, Thomas Graf wrote:
> >The addition won't be a revolution but it the increased header size,
> >8 vs. 12 bytes isn't a big deal and gives us some additional room to
> >work with in the future.
> >
> >struct nlattr_ext {
> >	u16	oldlen;		/* 0 */
> >	u16	kind;		/* TCA_* */
> >	u8	type;		/* NLA_U32 */
> >	u8	flags;		/* NLA_F_* */
> >	u16	reserved;
> >	u32	length;
> >};
> 
> And while we're discussing this, surely there are no objections
> to bumping NLA_ALIGN to 8 at the same time..

We can't do that. That would break _everything_.
