From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] r8169: initialize rtl8169_stats seqlock
Date: Tue, 25 Feb 2014 08:50:13 +0100
Message-ID: <20140225075013.GA24636@pd.tnic>
References: <20140224231748.GA18598@pd.tnic>
 <20140225011228.GC14970@merlin.infradead.org>
 <20140224.203240.898686891281813790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, kyle@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:46520 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbaBYHuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 02:50:16 -0500
Content-Disposition: inline
In-Reply-To: <20140224.203240.898686891281813790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 24, 2014 at 08:32:40PM -0500, David Miller wrote:
> > Boris reports he's seeing:
> >> [    9.195943] INFO: trying to register non-static key.
> >> [    9.196031] the code is fine but needs lockdep annotation.
> >> [    9.196031] turning off the locking correctness validator.
> >> [    9.196031] CPU: 1 PID: 933 Comm: modprobe Not tainted 3.14.0-rc4+ #1
> > with the r8169 driver.
> > 
> > These are occuring because the seqcount embedded in u64_stats_sync on
> > 32-bit SMP is uninitialized which is making lockdep unhappy.
> > 
> > Signed-off-by: Kyle McMartin <kyle@redhat.com>
> 
> Good catch, applied, thanks Kyle.

Thanks Kyle!

Tested-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
