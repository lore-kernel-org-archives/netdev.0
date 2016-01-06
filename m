From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: make JITs zero A for SKF_AD_ALU_XOR_X
Date: Wed, 06 Jan 2016 00:44:42 -0500 (EST)
Message-ID: <20160106.004442.109655096478479740.davem@davemloft.net>
References: <1452007387-626-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rabin@rab.in
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1452007387-626-1-git-send-email-rabin@rab.in>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rabin Vincent <rabin@rab.in>
Date: Tue,  5 Jan 2016 16:23:07 +0100

> The SKF_AD_ALU_XOR_X ancillary is not like the other ancillary data
> instructions since it XORs A with X while all the others replace A with
> some loaded value.  All the BPF JITs fail to clear A if this is used as
> the first instruction in a filter.  This was found using american fuzzy
> lop.
> 
> Add a helper to determine if A needs to be cleared given the first
> instruction in a filter, and use this in the JITs.  Except for ARM, the
> rest have only been compile-tested.
> 
> Fixes: 3480593131e0 ("net: filter: get rid of BPF_S_* enum")
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Applied and queued up for -stable, thanks!
