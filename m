From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH net v2 5/5] net: qcom/emac: fix of_node and phydev leaks
Date: Thu, 24 Nov 2016 12:55:24 -0600
Message-ID: <5837379C.4080400@codeaurora.org>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
 <1480011691-13278-6-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johan Hovold <johan@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-6-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johan Hovold wrote:
> Make sure to drop the reference taken by of_phy_find_device() during
> probe on probe errors and on driver unbind.
>
> Also drop the of_node reference taken by of_parse_phandle() in the same
> path.
>
> Fixes: b9b17debc69d ("net: emac: emac gigabit ethernet controller driver")
> Signed-off-by: Johan Hovold<johan@kernel.org>

When I first wrote this code, I had a lot of trouble getting the PHY to 
re-probe when the driver was unloaded and reloaded, and it was because 
of some odd problems with get/put of of_nodes.

Since I know that you didn't test this driver on real hardware, I have 
to test these patches myself before I can ACK them.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
