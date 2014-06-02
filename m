From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: add DMA initialization delay to device tree
Date: Mon, 02 Jun 2014 11:15:43 -0700 (PDT)
Message-ID: <20140602.111543.1026699389707378851.davem@davemloft.net>
References: <1401720835-21507-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hdegoede@redhat.com,
	peppe.cavallaro@st.com, wens@csie.org,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Vineet.Gupta1@synopsys.com
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401720835-21507-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Mon,  2 Jun 2014 18:53:55 +0400

> On some platforms existing 100 msecond delay is not enough for DMA block to
> recover after reset.
> For example MAC DMA waits for all PHY input clocks are present and depending
> on the board reset bit deassertion may take different amount of time.
> 
> Having this parameter easily configurable allows each board to have its own
> value, while all exisiting boards will continue to use current default value of
> 100 msec.
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Is there an upper bound for this you can just use?

It taking too long and timing out is an error condition, so just
using a limit value of "100" or something should be perfectly fine.

I don't think it's reasonable to put every conceivable nuance into
the DT nodes.

I'm not applying this patch, sorry.
