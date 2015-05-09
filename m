From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] test: bpf: extend "load 64-bit immediate" testcase
Date: Sat, 09 May 2015 23:12:23 +0200
Message-ID: <554E7837.6060002@iogearbox.net>
References: <1431159270-2960-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Will Deacon <will.deacon@arm.com>
To: Xi Wang <xi.wang@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431159270-2960-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/09/2015 10:14 AM, Xi Wang wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
