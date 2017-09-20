From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 3/4] samples/bpf: Fix pt_regs issues when cross-compiling
Date: Wed, 20 Sep 2017 23:25:01 +0200
Message-ID: <59C2DCAD.3090309@iogearbox.net>
References: <20170920161159.25747-1-joelaf@google.com> <20170920161159.25747-3-joelaf@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alison@she-devel.com, juri.lelli@arm.com,
        fengc@google.com, davem@davemloft.net, ast@kernel.org,
        kernel-team@android.com
To: Joel Fernandes <joelaf@google.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920161159.25747-3-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/20/2017 06:11 PM, Joel Fernandes wrote:
> BPF samples fail to build when cross-compiling for ARM64 because of incorrect
> pt_regs param selection. This is because clang defines __x86_64__ and
> bpf_headers thinks we're building for x86. Since clang is building for the BPF
> target, it shouldn't make assumptions about what target the BPF program is
> going to run on. To fix this, lets pass ARCH so the header knows which target
> the BPF program is being compiled for and can use the correct pt_regs code.
>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Joel Fernandes <joelaf@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
