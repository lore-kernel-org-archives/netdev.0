From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] arm64 BPF JIT updates
Date: Wed, 08 Jun 2016 00:30:33 -0700 (PDT)
Message-ID: <20160608.003033.955646634448015492.davem@davemloft.net>
References: <1465276979-10147-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: catalin.marinas@arm.com, will.deacon@arm.com, yang.shi@linaro.org,
	ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: zlim.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161418AbcFHHaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 03:30:35 -0400
In-Reply-To: <1465276979-10147-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zi Shen Lim <zlim.lnx@gmail.com>
Date: Mon,  6 Jun 2016 22:22:55 -0700

> Updates for arm64 eBPF JIT.
> The main addition here is implementation of bpf_tail_call.
> 
> #1: Fix missing header inclusion in linux/bpf.h.
> #2: Add bpf_tail_call for arm64.
> #3,4: Optimizations to reduce instruction count for jitted code.
> 
> Changes since v1:
>  - Added patch #1 to address build error due to missing header inclusion
>    in linux/bpf.h. (Thanks to suggestion and ack by Daniel Borkmann)
>    Ordered it ahead of bpf_tail_call patch #2 so build error is not
>    triggered.
> 
> Zi Shen Lim (4):
>   bpf: fix missing header inclusion
>   arm64: bpf: implement bpf_tail_call() helper
>   arm64: bpf: optimize JMP_CALL
>   arm64: bpf: optimize LD_ABS, LD_IND

I only see patches 1, 3, and 4 on the list.

Please resubmit.
