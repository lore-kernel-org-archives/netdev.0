From: David Miller <davem@davemloft.net>
Subject: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Fri, 24 Mar 2017 10:17:34 -0700 (PDT)
Message-ID: <20170324.101734.2195203757001166516.davem@davemloft.net>
References: <abf8722f-5d3a-0bae-d6cd-6cc6fbb744cb@synopsys.com>
        <748685e5-86f8-5f6b-66db-04ec96af4bd6@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clabbe.montjoie@gmail.com, thierry.reding@gmail.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41560 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966906AbdCXRRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:17:36 -0400
In-Reply-To: <748685e5-86f8-5f6b-66db-04ec96af4bd6@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 24 Mar 2017 15:02:27 +0000

> Yes, I agree, it is better to revert and leave the tree functional for all.
> 
> @David Miller:
> The multiple-buffer patch introduced some problems in some setups that are being
> hard to debug, so Corentin gave the idea of reverting the until
> commit 7bac4e1ec3ca2342929a39638d615c6b672c27a0 (net: stmmac: stmmac interrupt
> treatment prepared for multiple queues), which I fully agree.
> 
> In my setup is ok, but the idea is to have everyone's setup working :), so lets
> break them into smaller pieces, and let's only apply them when everyone confirms
> that is working ok in your setups, agree?
> 
> What is the typical mechanism for this? I send a patch reverting them?

If you can compose a single "git revert" command to achieve this, just
tell me what it is and I'll do it.

Otherwise send a patch that does the revert.

Thanks.
