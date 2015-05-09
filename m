From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ARM: net fix emit_udiv() for BPF_ALU | BPF_DIV |
 BPF_K intruction.
Date: Sat, 09 May 2015 17:40:53 -0400 (EDT)
Message-ID: <20150509.174053.1205273752891974916.davem@davemloft.net>
References: <1430929916-15852-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, mgherzan@gmail.com, daniel@iogearbox.net,
	ast@plumgrid.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: nschichan@freebox.fr
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1430929916-15852-1-git-send-email-nschichan@freebox.fr>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Wed,  6 May 2015 18:31:56 +0200

> In that case, emit_udiv() will be called with rn == ARM_R0 (r_scratch)
> and loading rm first into ARM_R0 will result in jit_udiv() function
> being called the same dividend and divisor. Fix that by loading rn
> first into ARM_R1 and then rm into ARM_R0.
> 
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> Cc: <stable@vger.kernel.org> # v3.13+
> Fixes: aee636c4809f (bpf: do not use reciprocal divide)

Do you want me to push this via my net tree?
