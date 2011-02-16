From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Subject: Re: [PATCH] ip: reuse ip_summed of first fragment for all subsequent fragments
Date: Wed, 16 Feb 2011 11:10:56 +0200
Message-ID: <844o844a5b.fsf@sauna.l.org>
References: <1292841525-15572-1-git-send-email-timo.lindfors@iki.fi>
	<20101228.134905.183040321.davem@davemloft.net>
	<84mxn7czz4.fsf@sauna.l.org>
	<20110112.184220.250810179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.academica.fi ([194.29.197.65]:60868 "EHLO
	smtp11.academica.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758757Ab1BPJRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 04:17:22 -0500
In-Reply-To: <20110112.184220.250810179.davem@davemloft.net> (David Miller's
	message of "Wed, 12 Jan 2011 18:42:20 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> You're now not handling the code block above this one, guarded
> by the "if (len <= 0)" check.

Yes that's true. Should we use skb_copy_bits() when sk->sk_no_check ==
UDP_CSUM_NOXMIT?

> You seem to just be peppering checks all over the place rather
> than coming up with a coherent, complete, fix for this problem.

I can understand that but I'm afraid that I lack the expertise to do
that. I might be able to fix the above problem but I can't be sure that
it is the only one. The bug report will remain at

https://bugzilla.kernel.org/show_bug.cgi?id=24832

in case somebody wants to continue from here.
