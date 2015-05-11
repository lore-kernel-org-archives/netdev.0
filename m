From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test: bpf: extend "load 64-bit immediate"
 testcase
Date: Mon, 11 May 2015 11:02:43 -0400 (EDT)
Message-ID: <20150511.110243.2159872075854721566.davem@davemloft.net>
References: <1431159270-2960-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ast@plumgrid.com, will.deacon@arm.com
To: xi.wang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431159270-2960-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xi Wang <xi.wang@gmail.com>
Date: Sat,  9 May 2015 04:14:30 -0400

> Extend the testcase to catch a signedness bug in the arm64 JIT:
> 
> test_bpf: #58 load 64-bit immediate jited:1 ret -1 != 1 FAIL (1 times)
> 
> This is useful to ensure other JITs won't have a similar bug.
> 
> Link: https://lkml.org/lkml/2015/5/8/458
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied, thank you.
