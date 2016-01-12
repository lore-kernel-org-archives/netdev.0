From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 15:56:09 -0500 (EST)
Message-ID: <20160112.155609.526505451119578505.davem@davemloft.net>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
	<1452626228-15742-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	linux-arm-kernel@lists.infradead.org
To: rabin@rab.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbcALU4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:56:11 -0500
In-Reply-To: <1452626228-15742-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin@rab.in>
Date: Tue, 12 Jan 2016 20:17:08 +0100

> On ARM64, a BUG() is triggered in the eBPF JIT if a filter with a
> constant shift that can't be encoded in the immediate field of the
> UBFM/SBFM instructions is passed to the JIT.  Since these shifts
> amounts, which are negative or >= regsize, are invalid, reject them in
> the eBPF verifier and the classic BPF filter checker, for all
> architectures.
> 
> Signed-off-by: Rabin Vincent <rabin@rab.in>
> ---
> v2: handle BPF_ARSH too

Applied and queued up for -stable, thanks.
