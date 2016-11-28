From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net 11/16] net: ethernet: marvell: mvneta: fix
 fixed-link phydev leaks
Date: Mon, 28 Nov 2016 21:10:00 +0100
Message-ID: <20161128211000.506ad0da@free-electrons.com>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
        <1480357509-28074-12-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Vince Bridgers <vbridger@opensource.altera.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Li Yang <leoli@freescale.com>, Felix Fietkau <nbd@openwrt.org>,
        John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Lars Persson <lars.persson@axis.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfa
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480357509-28074-12-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, 28 Nov 2016 19:25:04 +0100, Johan Hovold wrote:
> Make sure to deregister and free any fixed-link PHY registered using
> of_phy_register_fixed_link() on probe errors and on driver unbind.
> 
> Fixes: 83895bedeee6 ("net: mvneta: add support for fixed links")
> Signed-off-by: Johan Hovold <johan@kernel.org>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 5 +++++
>  1 file changed, 5 insertions(+)

Reviewed-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
