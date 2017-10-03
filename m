From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: lan9303: make functions
 lan9303_mdio_phy_{read|write} static
Date: Tue, 03 Oct 2017 10:20:24 -0700 (PDT)
Message-ID: <20171003.102024.1382587331164513041.davem@davemloft.net>
References: <20171003103918.26934-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171003103918.26934-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue,  3 Oct 2017 11:39:18 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The functions lan9303_mdio_phy_write and lan9303_mdio_phy_read are local
> to the source and do not need to be in global scope, so make them static.
> 
> Cleans up sparse warnings:
> symbol 'lan9303_mdio_phy_write' was not declared. Should it be static?
> symbol 'lan9303_mdio_phy_read' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
