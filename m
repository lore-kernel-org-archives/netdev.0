From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] via-rhine: Split driver into .c and .h files.
Date: Sun, 1 Jan 2012 23:49:09 +0100
Message-ID: <20120101224909.GA18144@electric-eye.fr.zoreil.com>
References: <1325452525-23476-1-git-send-email-gurligebis@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1325452525-23476-1-git-send-email-gurligebis@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
> Split the driver into via-rhine.c and via-rhine.h like it should be.
> There is also a bit of cleanup of checkpatch warnings, other than that,
> there is no changes to how the code works, it is plain refactoring.

Please don't do that. The .h won't be used elsewhere. It's useless
(and register definitions stay barely readable).

Roger, any comment regarding patches #1 .. #3 ?

rhine_task_{enable / disable} should be balanced in open / close and
suspend / resume, ok.

-- 
Ueimor
