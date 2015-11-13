From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH 1/2] arm64: bpf: fix JIT frame pointer setup
Date: Thu, 12 Nov 2015 19:21:13 -0800
Message-ID: <CABg9mctFoXuttJkGaqOBWm-beDKzui_Fwhj4u+iBBWPXAFsYwQ@mail.gmail.com>
References: <1447365421-1309-1-git-send-email-yang.shi@linaro.org>
	<1447365421-1309-2-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36449 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754469AbbKMDVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 22:21:15 -0500
In-Reply-To: <1447365421-1309-2-git-send-email-yang.shi@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2015 at 1:57 PM, Yang Shi <yang.shi@linaro.org> wrote:
> BPF fp should point to the top of the BPF prog stack. The original
> implementation made it point to the bottom incorrectly.
> Move A64_SP to fp before reserve BPF prog stack space.
>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> CC: Xi Wang <xi.wang@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---

Reviewed-by: Zi Shen Lim <zlim.lnx@gmail.com>

Also,

Fixes: e54bcde3d69d ("arm64: eBPF JIT compiler")
Cc: <stable@vger.kernel.org> # 3.18+
