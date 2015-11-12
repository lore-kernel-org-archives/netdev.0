From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: samples: exclude asm/sysreg.h for arm64
Date: Thu, 12 Nov 2015 14:42:09 -0800
Message-ID: <20151112224208.GA64046@ast-mbp.thefacebook.com>
References: <1447366066-2203-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447366066-2203-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 02:07:46PM -0800, Yang Shi wrote:
> commit 338d4f49d6f7114a017d294ccf7374df4f998edc
> ("arm64: kernel: Add support for Privileged Access Never") includes sysreg.h
> into futex.h and uaccess.h. But, the inline assembly used by asm/sysreg.h is
> incompatible with llvm so it will cause BPF samples build failure for ARM64.
> Since sysreg.h is useless for BPF samples, just exclude it from Makefile via
> defining __ASM_SYSREG_H.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

not the prettiest fix, but good enough for sample code.
Acked-by: Alexei Starovoitov <ast@kernel.org>
