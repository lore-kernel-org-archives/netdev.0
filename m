From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: stmmac: Fix race between stmmac_drv_probe and
 stmmac_open
Date: Tue, 27 Dec 2016 21:32:44 -0500 (EST)
Message-ID: <20161227.213244.1031537802471524150.davem@davemloft.net>
References: <F54AEECA5E2B9541821D670476DAE19C5A916C0E@PGSMSX102.gar.corp.intel.com>
        <20161228022306.14442-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pavel@ucw.cz, Joao.Pinto@synopsys.com,
        seraphin.bonnaffe@st.com, alexandre.torgue@gmail.com,
        manabian@gmail.com, niklas.cassel@axis.com, johan@kernel.org,
        boon.leong.ong@intel.com, weifeng.voon@intel.com,
        lars.persson@axis.com, linux-kernel@vger.kernel.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161228022306.14442-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 27 Dec 2016 18:23:06 -0800

> There is currently a small window during which the network device registered by
> stmmac can be made visible, yet all resources, including and clock and MDIO bus
> have not had a chance to be set up, this can lead to the following error to
> occur:
 ...
> Fix this by making sure that register_netdev() is the last thing being done,
> which guarantees that the clock and the MDIO bus are available.
> 
> Fixes: 4bfcbd7abce2 ("stmmac: Move the mdio_register/_unregister in probe/remove")
> Reported-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks Florian.
