From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix DMA buffer unmapping in mvneta_rx()
Date: Tue, 15 Sep 2015 14:55:20 -0700 (PDT)
Message-ID: <20150915.145520.1652469541141080343.davem@davemloft.net>
References: <20150915203634.GI7306@kw.sim.vm.gnt>
	<1442349681-27437-1-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oren@igneous.io, jason@lakedaemon.net, andrew@lunn.ch,
	gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com, vdonnefort@gmail.com,
	yoann@sculo.fr, mxs@sbrk.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: simon.guinot@sequanux.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1442349681-27437-1-git-send-email-simon.guinot@sequanux.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Guinot <simon.guinot@sequanux.org>
Date: Tue, 15 Sep 2015 22:41:21 +0200

> This patch fixes a regression introduced by the commit a84e32894191
> ("net: mvneta: fix refilling for Rx DMA buffers"). Due to this commit
> the newly allocated Rx buffers are DMA-unmapped in place of those passed
> to the networking stack. Obviously, this causes data corruptions.
> 
> This patch fixes the issue by ensuring that the right Rx buffers are
> DMA-unmapped.
> 
> Reported-by: Oren Laskin <oren@igneous.io>
> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> Fixes: a84e32894191 ("net: mvneta: fix refilling for Rx DMA buffers")

Applied, thanks.
