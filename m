From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 7/8] net/wan/fsl_ucc_hdlc: add hdlc-bus support
Date: Thu, 18 May 2017 10:29:49 -0400 (EDT)
Message-ID: <20170518.102949.388326359795971312.davem@davemloft.net>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
        <20170517152439.8817-7-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qiang.zhao@nxp.com
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754085AbdERO34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:29:56 -0400
In-Reply-To: <20170517152439.8817-7-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Wed, 17 May 2017 17:24:38 +0200

> This adds support for hdlc-bus mode to the fsl_ucc_hdlc driver. This can
> be enabled with the "fsl,hdlc-bus" property in the DTS node of the
> corresponding ucc.
> 
> This aligns the configuration of the UPSMR and GUMR registers to what is
> done in our ucc_hdlc driver (that only support hdlc-bus mode) and with
> the QuickEngine's documentation for hdlc-bus mode.
> 
> GUMR/SYNL is set to AUTO for the busmode as in this case the CD signal
> is ignored. The brkpt_support is enabled to set the HBM1 bit in the
> CMXUCR register to configure an open-drain connected HDLC bus.
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>

Applied.
