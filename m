From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/8] net/wan/fsl_ucc_hdlc: call qe_setbrg only
 for loopback mode
Date: Thu, 18 May 2017 10:29:38 -0400 (EDT)
Message-ID: <20170518.102938.786689275145858326.davem@davemloft.net>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
        <20170517152439.8817-5-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qiang.zhao@nxp.com
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751486AbdERO3o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:29:44 -0400
In-Reply-To: <20170517152439.8817-5-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Wed, 17 May 2017 17:24:36 +0200

> We can't assume that we are always in loopback mode if rx and tx clock
> have the same clock source. If we want to use HDLC busmode we also have
> the same clock source but we are not in loopback mode. So move the
> setting of the baudrate generator after the check for property for the
> loopback mode.
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>

Applied.
