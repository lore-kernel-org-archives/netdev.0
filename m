From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 0/4] Pull request for 'ipg-fixes' branch
Date: Fri, 11 Jan 2008 18:22:16 +0100
Message-ID: <20080111172216.GA3927@electric-eye.fr.zoreil.com>
References: <20080110233508.GA13315@electric-eye.fr.zoreil.com> <20080111015851.25008.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org, jeff@garzik.org,
	netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41425 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759283AbYAKRfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:35:51 -0500
Content-Disposition: inline
In-Reply-To: <20080111015851.25008.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux@horizon.com <linux@horizon.com> :
[...]
> I notice that the vendor-supplied driver doesn't have these bugs.

The M in POMS stands for "my".

[...]
> Would you be interested in some cleanup patches ?

Yes.

> In particular, I think I can get rid of tx->lock entirely, or at least
> take it off the fast path. All it's protecting is the write to
> sp->tx_current, and a few judicious memory barriers can deal with that.

I have done a kind of memory barrier trick for the r8169 in the past but
it is not clear that I would do it again. Today I would argue more strongly
in direction of similar locking amongst different drivers. The tg3 driver
is a good model imho.

Anyway you have been here for some time so I see no reason to kill any
different/new locking scheme you could come with.

Off until sunday.

-- 
Ueimor
