From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 23:02:30 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011092302070.28314@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net> <20101108151635.GA20629@canuck.infradead.org> <4CD91406.4000603@trash.net> <20101109144941.GA4018@canuck.infradead.org> <alpine.LNX.2.01.1011092113420.10710@obet.zrqbmnf.qr>
 <20101109214039.GA11005@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:39587 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448Ab0KIWCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 17:02:31 -0500
In-Reply-To: <20101109214039.GA11005@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2010-11-09 22:40, Thomas Graf wrote:
>The addition won't be a revolution but it the increased header size,
>8 vs. 12 bytes isn't a big deal and gives us some additional room to
>work with in the future.
>
>struct nlattr_ext {
>	u16	oldlen;		/* 0 */
>	u16	kind;		/* TCA_* */
>	u8	type;		/* NLA_U32 */
>	u8	flags;		/* NLA_F_* */
>	u16	reserved;
>	u32	length;
>};

And while we're discussing this, surely there are no objections
to bumping NLA_ALIGN to 8 at the same time..
