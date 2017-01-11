From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] remove dwc_eth_qos and rename stmicro/stmmac
Date: Wed, 11 Jan 2017 09:52:56 -0500 (EST)
Message-ID: <20170111.095256.1057845755758556047.davem@davemloft.net>
References: <cover.1484059674.git.jpinto@synopsys.com>
        <0dcdcb5f-200b-b130-9a67-774639353114@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joao.Pinto@synopsys.com, lars.persson@axis.com, niklass@axis.com,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932553AbdAKOw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 09:52:58 -0500
In-Reply-To: <0dcdcb5f-200b-b130-9a67-774639353114@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Torgue <alexandre.torgue@st.com>
Date: Wed, 11 Jan 2017 12:39:09 +0100

> Let's see what David think about that but if there no risk of backward
> compatibility with DT, I agree with the series.

I really am generally against driver renames.  The only potentially
make new users happy, but can only negatively impact existing users.

The new name is not terribly appropriate either, it is using the name
of the manufacturer rather than referring to a chipset or a class or
chipsets.

I don't see what the big deal is in leaving the name as 'stmmac' and
in a way leaving it alone shows respect for the people who have worked
on and cared for the stmmac driver for all of these years.

Thanks.
