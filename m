From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ftgmac100: Increase reset timeout
Date: Mon, 24 Jul 2017 17:24:16 -0700 (PDT)
Message-ID: <20170724.172416.1265262962457308363.davem@davemloft.net>
References: <1500879541.10674.62.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joel.stanley@au1.ibm.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755525AbdGYAYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:24:17 -0400
In-Reply-To: <1500879541.10674.62.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 24 Jul 2017 16:59:01 +1000

> We had reports of 50us not being sufficient to reset the MAC,
> thus hitting the "Hardware reset failed" error bringing the
> interface up on some AST2400 based machines.
> 
> This bumps the timeout to 200us.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Applied.
