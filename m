From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] stmmac: fix Transmit Underflow error
Date: Mon, 11 Apr 2011 12:56:39 -0700 (PDT)
Message-ID: <20110411.125639.104063930.davem@davemloft.net>
References: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
	<1302513406-3758-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53189
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755768Ab1DKT5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 15:57:15 -0400
In-Reply-To: <1302513406-3758-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 11 Apr 2011 11:16:46 +0200

> On some old MAC chips without COE sometime the
> Transmit Underflow error is issued.
> 
> The driver aborted all the transmission process
> and initialized it from scratch.
> This breaks the network activity as raised by Nachiketa
> on a SPEAr board.
> 
> The patch is to fix this rare underflow event.
> The driver will only clear the interrupt and the Tx
> DMA will go out the Suspend state as soon as the
> descriptor is fetched again.
> The driver will continue to bump-up the DMA FIFO threshold
> that, indeed, helped somebody to prevent this kind of error
> in the past as well.
> 
> Reported-by: Nachiketa Prachanda <nprachanda@ncomputing.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
