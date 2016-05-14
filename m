From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arm64: bpf: jit JMP_JSET_{X,K}
Date: Sat, 14 May 2016 16:12:06 -0400 (EDT)
Message-ID: <20160514.161206.373725987038622109.davem@davemloft.net>
References: <1463121478-18484-1-git-send-email-zlim.lnx@gmail.com>
	<20160513095718.GB13689@arm.com>
	<20160513100307.GC13689@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zlim.lnx@gmail.com, ast@kernel.org, catalin.marinas@arm.com,
	daniel@iogearbox.net, yang.shi@linaro.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: will.deacon@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790AbcENUML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 16:12:11 -0400
In-Reply-To: <20160513100307.GC13689@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Deacon <will.deacon@arm.com>
Date: Fri, 13 May 2016 11:03:07 +0100

> On Fri, May 13, 2016 at 10:57:18AM +0100, Will Deacon wrote:
>> On Thu, May 12, 2016 at 11:37:58PM -0700, Zi Shen Lim wrote:
>> > Original implementation commit e54bcde3d69d ("arm64: eBPF JIT compiler")
>> > had the relevant code paths, but due to an oversight always fail jiting.
>> > 
>> > As a result, we had been falling back to BPF interpreter whenever a BPF
>> > program has JMP_JSET_{X,K} instructions.
>> > 
>> > With this fix, we confirm that the corresponding tests in lib/test_bpf
>> > continue to pass, and also jited.
>> > 
>> > ...
>> > [    2.784553] test_bpf: #30 JSET jited:1 188 192 197 PASS
>> > [    2.791373] test_bpf: #31 tcpdump port 22 jited:1 325 677 625 PASS
>> > [    2.808800] test_bpf: #32 tcpdump complex jited:1 323 731 991 PASS
>> > ...
>> > [    3.190759] test_bpf: #237 JMP_JSET_K: if (0x3 & 0x2) return 1 jited:1 110 PASS
>> > [    3.192524] test_bpf: #238 JMP_JSET_K: if (0x3 & 0xffffffff) return 1 jited:1 98 PASS
>> > [    3.211014] test_bpf: #249 JMP_JSET_X: if (0x3 & 0x2) return 1 jited:1 120 PASS
>> > [    3.212973] test_bpf: #250 JMP_JSET_X: if (0x3 & 0xffffffff) return 1 jited:1 89 PASS
>> > ...
>> > 
>> > Fixes: e54bcde3d69d ("arm64: eBPF JIT compiler")
>> > Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
 ...
> Acked-by: Will Deacon <will.deacon@arm.com>
> 
> I'm assuming David will queue this?

Yep I got this, applied, thanks.
