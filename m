From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] forcedeth: allow to silence tx_timeout debug
 messages
Date: Wed, 18 May 2011 17:16:03 -0400 (EDT)
Message-ID: <20110518.171603.2048423328863525352.davem@davemloft.net>
References: <1305753000-14933-1-git-send-email-decot@google.com>
	<1305753000-14933-2-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, szymon@janc.net.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-net-upstream@google.com,
	snanda@google.com
To: decot@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305753000-14933-2-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@google.com>
Date: Wed, 18 May 2011 14:10:00 -0700

> From: Sameer Nanda <snanda@google.com>
> 
> This change allows to silence most debug messages in case of TX
> timeout. These messages don't provide a signare/noise ratio high
> enough for production systems and, with ~30kB logged each time, they
> tend to add to a cascade effect if the system is already under stress
> (memory pressure, disk, etc.).
> 
> By default, the debug messages are not displayed but this can be
> overriden by setting the debug_tx_timeout module parameter.
> 
> 
> Signed-off-by: David Decotigny <decot@google.com>

I would rather you make the messages less verbose, instead of
having it say absolutely nothing when this happens as it is
a serious problem.

You can add a knob which when enabled gives the old verbosity
back for diagnostic purposes.
