From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: stmicro: eQOS IP Core
Date: Fri, 20 Jan 2017 11:20:25 -0500 (EST)
Message-ID: <20170120.112025.283503761726233382.davem@davemloft.net>
References: <4584830fd1416af69ddb2e0168f78b1e343c33fe.1484914583.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60758 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753000AbdATQU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:20:27 -0500
In-Reply-To: <4584830fd1416af69ddb2e0168f78b1e343c33fe.1484914583.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 20 Jan 2017 12:27:33 +0000

> For historical reasons the Designware eQOS IP Core started in version 4.x,
> instead of starting in 1.x. This caused some misunderstanding, which resulted
> in calling this IP as GMAC4. If you go to Synopsys website and check the
> Ethernet portfolio there is no GMAC4 IP:
> https://www.synopsys.com/designware-ip/interface-ip/ethernet.html
> 
> There is a new version of eQOS comming out (5.x) that will have the same
> mac, dma registers and flow, with an extra set of registers to enable
> features like TSN. The creation of a dwmac5 or gmac5 would be wrong, and
> including those new features related to eQOS 5.x in dwmac4 would also not
> be very correct.
> 
> This patch suggests to rename dwmac4_* driver to eqos_*, turning it the
> official driver for eQOS IP. The registers definitions are also now
> called QOS_ instead of GMAC4_.
> 
> For more information about eQOS IP please check:
> https://www.synopsys.com/dw/ipdir.php?ds=dwc_ether_qos
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Sorry, you're not renaming every function in the driver that meets this
qualification.

I understand you want to work hard on the driver, but part of that is
_accepting_ things how they have been for years and making code
improvements and additions rather than messing around playing
rename-this/rename-that games until it looks how you want it to.

Please stop this charade of renaming, I'm getting really tired of it and
I think you really have no concept what kind of effect it has on people
who have to review, apply, and backport this code.

Kconfig text changes and clarifications, that's fine.  But all of these
function and variable name changes to the driver, and comment sweeps, no
it is not acceptable to me.
