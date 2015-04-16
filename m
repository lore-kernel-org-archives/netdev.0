From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] stmmac: Correct flow control configuration
Date: Thu, 16 Apr 2015 14:09:12 -0400 (EDT)
Message-ID: <20150416.140912.996227200455677055.davem@davemloft.net>
References: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vbridger@altera.com
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Wed, 15 Apr 2015 11:17:37 -0500

> This series of patches corrects flow control configuration for the Synopsys
> GMAC driver.
> 
> Flow control is configured based on a configurable receive fifo size. If
> less than 4Kbytes flow control is left disabled and a warning is presented. If
> a receive fifo size is not specified, flow control is left disabled to
> maintain current behavior. Unicast pause detection was disabled, but is now 
> enabled. The pause time was modified to be maximum time per a XON/XOFF
> flow control mode of operation.
> 
> This patch was tested on an Altera Cyclone 5 and an Altera Arria 10 devkit,
> and verified that flow control operates as expected when enabled.
> 
> Please consider this series for inclusion so that flow control will
> function as expected for the Synopsys GMAC controller. 

Series applied, thanks.
