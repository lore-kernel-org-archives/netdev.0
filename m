From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH 0/5] net: macb: Fixes
Date: Thu, 22 May 2014 15:18:28 +0200
Message-ID: <20140522131827.GN3582@piout.net>
References: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Simek <michal.simek@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	git@xilinx.com, linux-kernel@vger.kernel.org
To: Soren Brinkmann <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 04/05/2014 at 15:42:57 -0700, Soren Brinkmann wrote :
> 
> Hi Nicolas,
> 
> I think I found the cause of the issue I told you about. Looks like
> driver and HW are racing (a few more details in the commit message).
> On my way finding that, I found a few more minor issues which are fixed
> in the first patches.
> The last one is "fixing" the actual race. I don't know if I overlooked
> anything here, but this seems to work fine on Zynq.
> 

Tested on at91sam9g45ek with iperf showing good performances. For the
whole series:
Tested-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>


-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
