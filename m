From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Fri, 24 Mar 2017 08:42:55 +0100
Message-ID: <20170324074255.GB16730@lunn.ch>
References: <1eb1ee4c84f61ff8dbc3f398f2e3f9b0bea3ee30.1489766674.git.jpinto@synopsys.com>
 <20170323171725.GA12548@ulmo.ba.sec>
 <2ec8451b-4d12-d7ea-a2ce-4f1add382df4@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thierry Reding <thierry.reding@gmail.com>, davem@davemloft.net,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59429 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751313AbdCXHnE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 03:43:04 -0400
Content-Disposition: inline
In-Reply-To: <2ec8451b-4d12-d7ea-a2ce-4f1add382df4@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 05:27:08PM +0000, Joao Pinto wrote:

> Yes, you are correct. It should be priv->plat->tx_queues_to_use instead of "u32
> tx_count = priv->dma_cap.number_tx_queues;"... sorry for that, but in my setup
> is the same value. Could you please make a patch for it?

Hi Joao

As the new maintainer, don't you think you should be testing on
multiple systems? There are SoC vendor reference design boards you can
buy, and set up a test farm. You can then ensure your new features
don't break stuff, or add performance regressions.

      Andrew
