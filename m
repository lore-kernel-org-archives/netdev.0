From: David Miller <davem@davemloft.net>
Subject: Re: Performance in stmmac
Date: Wed, 08 Feb 2017 13:40:15 -0500 (EST)
Message-ID: <20170208.134015.2186033581160265708.davem@davemloft.net>
References: <1d4da3b4-d798-e55a-3988-647adbfd8413@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niklas.cassel@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdBHTf4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:35:56 -0500
In-Reply-To: <1d4da3b4-d798-e55a-3988-647adbfd8413@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Tue, 7 Feb 2017 19:33:52 +0000

> I am seeing tx being performed in all queues, but rx is just being routed to
> queue 0. The reason why only queue 0 is processing the packets is because I am
> using priority tagged routing for now and iperf is not capable of producing
> priority tagged traffic.
> 
> I am sending you this e-mail in order to know if you could suggest me a tool to
> generate priority tagged traffic and if you have experience in tweaking stmmac
> to improve performance.

Multi-queue is only going to be effective on RX if you can do proper hashed
flow separation.  That's the entire performance point of the feature.

If the chip cannot do this, your performance will be thusly limited.
