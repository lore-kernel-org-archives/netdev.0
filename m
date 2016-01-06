From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ARM: net: bpf: fix zero right shift
Date: Wed, 06 Jan 2016 01:32:29 -0500 (EST)
Message-ID: <20160106.013229.122000813125865535.davem@davemloft.net>
References: <1452015244-1230-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org
To: rabin@rab.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbcAFGcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 01:32:31 -0500
In-Reply-To: <1452015244-1230-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin@rab.in>
Date: Tue,  5 Jan 2016 18:34:04 +0100

> The LSR instruction cannot be used to perform a zero right shift since a
> 0 as the immediate value (imm5) in the LSR instruction encoding means
> that a shift of 32 is perfomed.  See DecodeIMMShift() in the ARM ARM.
> 
> Make the JIT skip generation of the LSR if a zero-shift is requested.
> 
> This was found using american fuzzy lop.
> 
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Applied, thanks.
