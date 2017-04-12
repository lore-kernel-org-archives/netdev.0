From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status
 feature
Date: Wed, 12 Apr 2017 10:51:01 -0400 (EDT)
Message-ID: <20170412.105101.58827766857310782.davem@davemloft.net>
References: <37cc8294-5514-ed02-9b41-86f8cc9c20ad@synopsys.com>
        <20170412135239.GD32596@lunn.ch>
        <efbda38a-2146-06b2-9151-19294c654d28@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752432AbdDLOvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:51:08 -0400
In-Reply-To: <efbda38a-2146-06b2-9151-19294c654d28@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed, 12 Apr 2017 14:55:03 +0100

> Understand your point, but for now our development and testing setup will be
> based on the IP Prototyping Kit, consisting of a FPGA + PHY.

That's completely, and utterly, unacceptable.

I will be quite frank with you, that instances like this are causing
people to contact me privately and telling me that your handling of
becomming the stmmac driver maintainer is causing very real and
serious concerns.

You cannot develop performance based features and only test their
impact on FPGA when almost all users are on real silicon.

And this requirement is absolutely non-negotiable.

You must test the impact on real silicon otherwise your performance
numbers, which are required to be provided in the commit message
for any "performance" feature or change, are completely useless.

I want your attitude on these matters to change quickly, as myself
and many other interested parties are becomming extremely frustrated
with how you are handling things.

Thank you.
