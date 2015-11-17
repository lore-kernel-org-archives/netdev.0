From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH V4 2/2] arm64: bpf: make BPF prologue and epilogue align
 with ARM64 AAPCS
Date: Mon, 16 Nov 2015 20:41:46 -0800
Message-ID: <20151117044145.GA71069@ast-mbp.thefacebook.com>
References: <CABg9mcvomep=M1As_Vj=XuTNk=jiGwXQqQWbjotMXP2csKX=Bg@mail.gmail.com>
 <1447713335-29707-1-git-send-email-yang.shi@linaro.org>
 <CABg9mcvh+SLK-1iF28pCQgXt5WM_H4tH3ntgKSkMHCyMygThgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33072 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbKQElw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 23:41:52 -0500
Content-Disposition: inline
In-Reply-To: <CABg9mcvh+SLK-1iF28pCQgXt5WM_H4tH3ntgKSkMHCyMygThgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2015 at 08:37:11PM -0800, Z Lim wrote:
> On Mon, Nov 16, 2015 at 2:35 PM, Yang Shi <yang.shi@linaro.org> wrote:
> > Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
> > in prologue in order to get the correct stack backtrace.
...
> > CC: Zi Shen Lim <zlim.lnx@gmail.com>
> > CC: Xi Wang <xi.wang@gmail.com>
> > Signed-off-by: Yang Shi <yang.shi@linaro.org>
> 
> Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>

great that it's finalized.
Yang, please resubmit both patches to netdev as fresh submission so it
gets picked up by patchwork.
