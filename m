From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ARM: net: JIT compiler for packet filters
Date: Tue, 20 Dec 2011 13:55:26 -0500 (EST)
Message-ID: <20111220.135526.82432216865290827.davem@davemloft.net>
References: <1324404263-913-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk
To: mgherzan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab1LTS6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 13:58:50 -0500
In-Reply-To: <1324404263-913-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mircea Gherzan <mgherzan@gmail.com>
Date: Tue, 20 Dec 2011 19:04:23 +0100

> Based of Matt Evans's PPC64 implementation.
> 
> The compiler generates ARM instructions but interworking is
> supported for Thumb2 kernels.
> 
> Supports both little and big endian. Unaligned loads are emitted
> for ARMv6+. Not all the BPF opcodes that deal with ancillary data
> are supported. The scratch memory of the filter lives on the stack.
> Hardware integer division is used if it is available.
> 
> Enabled in the same way as for x86-64 and PPC64:
> 
> 	echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> A value greater than 1 enables opcode output.
> 
> Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>

I'm happy with this going in via the ARM tree once all the details
are worked out:

Acked-by: David S. Miller <davem@davemloft.net>
