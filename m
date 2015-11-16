From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: samples: exclude asm/sysreg.h for arm64
Date: Mon, 16 Nov 2015 14:41:17 -0500 (EST)
Message-ID: <20151116.144117.569968015208709281.davem@davemloft.net>
References: <1447366066-2203-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: yang.shi@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbbKPTlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:41:20 -0500
In-Reply-To: <1447366066-2203-1-git-send-email-yang.shi@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Shi <yang.shi@linaro.org>
Date: Thu, 12 Nov 2015 14:07:46 -0800

> commit 338d4f49d6f7114a017d294ccf7374df4f998edc
> ("arm64: kernel: Add support for Privileged Access Never") includes sysreg.h
> into futex.h and uaccess.h. But, the inline assembly used by asm/sysreg.h is
> incompatible with llvm so it will cause BPF samples build failure for ARM64.
> Since sysreg.h is useless for BPF samples, just exclude it from Makefile via
> defining __ASM_SYSREG_H.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Applied.
