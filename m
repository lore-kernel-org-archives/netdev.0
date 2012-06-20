From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 19 Jun 2012 21:24:23 -0700 (PDT)
Message-ID: <20120619.212423.1927278993583357087.davem@davemloft.net>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, federico.vaga@gmail.com,
	giancarlo.asnaghi@st.com, wg@grandegger.com, bhupesh.sharma@st.com,
	mkl@pengutronix.de
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 20 Jun 2012 13:33:48 +1000

> After merging the net-next tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> ERROR: "clk_get_rate" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> ERROR: "clk_get" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> ERROR: "clk_put" [drivers/net/can/c_can/c_can_pci.ko] undefined!
> 
> Caused by commit 5b92da0443c2 ("c_can_pci: generic module for C_CAN/D_CAN
> on PCI").  Maybe a missing Kconfig dependency/select?
> 
> I have used the net-next tree from next-20120619 for today.

Known problem:

http://marc.info/?l=linux-netdev&m=134014347620836&w=2
