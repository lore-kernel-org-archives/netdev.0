From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmicro: replace kzalloc with
 devm_kzalloc
Date: Thu, 09 Mar 2017 13:17:37 -0800 (PST)
Message-ID: <20170309.131737.1171109796957963393.davem@davemloft.net>
References: <4e6c083db31dc7a6991401d9d045d3cd89d069b1.1488900195.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdCIVRj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 16:17:39 -0500
In-Reply-To: <4e6c083db31dc7a6991401d9d045d3cd89d069b1.1488900195.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Tue,  7 Mar 2017 15:27:36 +0000

> The axi variable was not being freed upon device removal.
> With devm_kzalloc it ensures that it is properly freed.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied.
