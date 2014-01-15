From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net,via-rhine: Fix tx_timeout handling
Date: Wed, 15 Jan 2014 15:21:41 -0800 (PST)
Message-ID: <20140115.152141.736966534492130155.davem@davemloft.net>
References: <1389735996-4692-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com
To: richard@nod.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389735996-4692-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>
Date: Tue, 14 Jan 2014 22:46:36 +0100

> rhine_reset_task() misses to disable the tx scheduler upon reset,
> this can lead to a crash if work is still scheduled while we're resetting
> the tx queue.
> 
> Fixes:
> [   93.591707] BUG: unable to handle kernel NULL pointer dereference at 0000004c
> [   93.595514] IP: [<c119d10d>] rhine_napipoll+0x491/0x6
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Applied and queued up for -stable, thanks.
