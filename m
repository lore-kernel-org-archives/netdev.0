From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 1/4] samples/bpf: Use getppid instead of getpgrp for
 array map stress
Date: Wed, 20 Sep 2017 23:24:28 +0200
Message-ID: <59C2DC8C.1080504@iogearbox.net>
References: <20170920161159.25747-1-joelaf@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alison@she-devel.com, juri.lelli@arm.com,
        fengc@google.com, davem@davemloft.net, ast@kernel.org,
        kernel-team@android.com
To: Joel Fernandes <joelaf@google.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920161159.25747-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/20/2017 06:11 PM, Joel Fernandes wrote:
> When cross-compiling the bpf sample map_perf_test for aarch64, I find that
> __NR_getpgrp is undefined. This causes build errors. This syscall is deprecated
> and requires defining __ARCH_WANT_SYSCALL_DEPRECATED. To avoid having to define
> that, just use a different syscall (getppid) for the array map stress test.
>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Joel Fernandes <joelaf@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
