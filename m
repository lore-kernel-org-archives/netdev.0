From: David Miller <davem@davemloft.net>
Subject: Re: Synopsys Ethernet QoS
Date: Fri, 09 Dec 2016 10:41:52 -0500 (EST)
Message-ID: <20161209.104152.1969880574279771010.davem@davemloft.net>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
        <20161209.103327.1742213347114742435.davem@davemloft.net>
        <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, lars.persson@axis.com,
        rabin.vincent@axis.com, netdev@vger.kernel.org,
        andy.shevchenko@gmail.com, CARLOS.PALMINHA@synopsys.com
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754010AbcLIPl7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 10:41:59 -0500
In-Reply-To: <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 9 Dec 2016 15:36:38 +0000

> Of course, I started a general discussion about the subject and
> those were the conclusions, but I would like to know if you as the
> subsystem maintainer also support the approach or have any
> suggestion.

Generally, I support whatever the interested parties agree to.

But one thing I am against is changing the driver name for existing
users.  If an existing chip is supported by the stmmac driver for
existing users, they should still continue to use the "stmmac" driver.

Therefore, if consolidation changes the driver module name for
existing users, then that is not a good plan at all.
