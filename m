From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] test: bpf: extend "load 64-bit immediate" testcase
Date: Sat, 09 May 2015 09:11:06 -0700
Message-ID: <554E319A.2040905@plumgrid.com>
References: <1431159270-2960-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Will Deacon <will.deacon@arm.com>
To: Xi Wang <xi.wang@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431159270-2960-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/9/15 1:14 AM, Xi Wang wrote:
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
> ---

looks good. Thanks!

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
