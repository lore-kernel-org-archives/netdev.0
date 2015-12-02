From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RESEND PATCH] arm64: bpf: add 'store immediate' instruction
Date: Wed, 2 Dec 2015 09:15:18 +0000
Message-ID: <20151202091517.GA7311@arm.com>
References: <1448922247-5692-1-git-send-email-yang.shi@linaro.org>
 <565E1D38.7020906@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, catalin.marinas@arm.com, davem@davemloft.net,
	zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: "Shi, Yang" <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <565E1D38.7020906@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2015 at 02:20:40PM -0800, Shi, Yang wrote:
> On 11/30/2015 2:24 PM, Yang Shi wrote:
> >aarch64 doesn't have native store immediate instruction, such operation
> >has to be implemented by the below instruction sequence:
> >
> >Load immediate to register
> >Store register
> >
> >Signed-off-by: Yang Shi <yang.shi@linaro.org>
> >CC: Zi Shen Lim <zlim.lnx@gmail.com>
> 
> Had email exchange offline with Zi Shen Lim since he is traveling and cannot
> send text-only mail, quoted below for his reply:
> 
> "I've given reviewed-by in response to original posting. Unless something
> has changed, feel free to add it."
> 
> Since there is nothing changed, added his reviewed-by.
> 
> Reviewed-by: Zi Shen Lim <zlim.lnx@gmail.com>

I assume David will take this via netdev.

Will
