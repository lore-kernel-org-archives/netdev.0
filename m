From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/wan/fsl_ucc_hdlc: fix muram allocation
 error
Date: Mon, 22 May 2017 12:29:14 -0400 (EDT)
Message-ID: <20170522.122914.1304409644415649924.davem@davemloft.net>
References: <20170522073115.16393-1-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qiang.zhao@nxp.com
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932514AbdEVQ3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 12:29:15 -0400
In-Reply-To: <20170522073115.16393-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Mon, 22 May 2017 09:31:15 +0200

> sizeof(priv->ucc_pram) is 4 as it is the size of a pointer, but we want
> to reserve space for the struct ucc_hdlc_param.
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>

Applied.
