From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] arm64: insn: remove BUG_ON from codegen
Date: Fri, 15 Jan 2016 17:08:53 +0000
Message-ID: <20160115170852.GB1641@arm.com>
References: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Rabin Vincent <rabin@rab.in>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:54156 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762AbcAORI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 12:08:57 -0500
Content-Disposition: inline
In-Reply-To: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2016 at 11:33:21PM -0800, Zi Shen Lim wrote:
> During code generation, we used to BUG_ON unknown/unsupported encoding
> or invalid parameters.
> 
> Instead, now we report these as errors and simply return the
> instruction AARCH64_BREAK_FAULT. Users of these codegen helpers should
> check for and handle this failure condition as appropriate.
> 
> Otherwise, unhandled codegen failure will result in trapping at
> run-time due to AARCH64_BREAK_FAULT, which is arguably better than a
> BUG_ON.
> 
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> Cc: Will Deacon <will.deacon@arm.com>
> ---
> Per discussion here: http://www.spinics.net/lists/arm-kernel/msg474179.html

Thanks, this looks good to me. Given that Rabin fixes the shift issue
in the core, I'm assuming this can wait until 4.6 and Catalin can queue
it after -rc1?

  Acked-by: Will Deacon <will.deacon@arm.com>

Cheers,

Will
