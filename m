From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Wed, 11 Jan 2017 16:32:41 -0500 (EST)
Message-ID: <20170111.163241.796671207580364768.davem@davemloft.net>
References: <cover.1484059674.git.jpinto@synopsys.com>
        <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
        <5b5a3231-eed4-ef29-b32a-a19077681dad@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joao.Pinto@synopsys.com, lars.persson@axis.com, niklass@axis.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754204AbdAKVeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:34:00 -0500
In-Reply-To: <5b5a3231-eed4-ef29-b32a-a19077681dad@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 11 Jan 2017 13:14:32 -0800

> As mentioned before, although git is able to track renames, git log does
> not automatically have --follow, so it can be hard for people to track
> down the (new) history of the driver.
> 
> Personally, I don't see much value in doing this rename, especially when
> all the driver internal structures are still going to be named with
> stmmac (and please don't even think about doing a s/stmmac/snps/ inside
> the driver ;)).

I agree, this could really make long term maintainence and bug fix
backporting a nightmare for a lot of people.

Please strongly reconsider, I still don't see any true value in this
rename.
