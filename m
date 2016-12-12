From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: hisi_femac: Call SET_NETDEV_DEV()
Date: Mon, 12 Dec 2016 08:28:22 -0800
Message-ID: <c7beec12-fd09-20aa-f452-e559b44234a2@gmail.com>
References: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
 <1481544223-207906-2-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xuejiancheng@hisilicon.com, benjamin.chenhao@hisilicon.com,
        caizhiyong@hisilicon.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481544223-207906-2-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/12/2016 04:03 AM, Dongpo Li wrote:
> The hisi_femac driver calls into PHYLIB which now checks for
> net_device->dev.parent, so make sure we do set it before calling into
> any MDIO/PHYLIB related function.
> 
> Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
