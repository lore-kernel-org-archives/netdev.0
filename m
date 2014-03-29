From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 0/3] net: stmmac: Add glue layer for socfpga platform
Date: Sat, 29 Mar 2014 01:18:06 +0100
Message-ID: <201403290118.07163.arnd@arndb.de>
References: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: dinh.linux@gmail.com, davem@davemloft.net, peppe.cavallaro@st.com,
	srinivas.kandagatla@st.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, arm@kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56684 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbaC2ASY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 20:18:24 -0400
In-Reply-To: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 March 2014, dinguyen@altera.com wrote:
> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Hi David,
> 
> I'm re-submitting the patch series to add the socfpga glue layer for the
> stmmac ethernet driver. My original patch did not build for kernel module,
> and I apologize for not testing against that.
> 
> This patch is also better aligned with the other stmmac glue
> layers(sti and sunxi).
> 
> I'd like to take the "net: stmmac: Add SOCFPGA glue driver" patch into your
> tree and the other 2 dts patches through the arm-soc tree.

I've applied patches 2 and 3 to the arm-soc/next/dt branch now.

Unfortunately there is still one trivial conflict against the net-next tree
left in the binding document, but I'm not too worried about that.

	Arnd
