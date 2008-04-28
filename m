From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [RESEND][NETFILTER][PATCH] nfqnl_mangle() not requesting enough space for bigger reinjected packet.
Date: Tue, 29 Apr 2008 01:07:57 +0200
Message-ID: <87zlrdtw6q.fsf@natisbad.org>
References: <87abjdvpiq.fsf@natisbad.org> <481647F2.20507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:50808 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968366AbYD1XIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 19:08:05 -0400
In-Reply-To: <481647F2.20507@trash.net> (Patrick McHardy's message of "Mon, 28
	Apr 2008 23:56:02 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Patrick McHardy <kaber@trash.net> writes:

> Good catch, thanks. That code seems to be very resistent against
> attempts to fix it :)
>
> Patch applied, and I'll also send it to -stable once it hits
> upstream.

Ack.

BTW, while looking at the code, I noticed the call to skb_copy_expand()
leads to a complete copy of current sk_buff data to the new sk_buff.
Those data are then completely rewritten a few lines later. Too bad
there is no simple way (considering skbuff.h) to prevent the useless
copy.

Cheers,

a+

