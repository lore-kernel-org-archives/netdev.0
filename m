From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] net: fix device reference leaks
Date: Mon, 07 Nov 2016 13:18:03 -0500 (EST)
Message-ID: <20161107.131803.185357290115152377.davem@davemloft.net>
References: <1478194822-29545-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, mugunthanvnm@ti.com, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478194822-29545-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Thu,  3 Nov 2016 18:40:18 +0100

> This series fixes a number of device reference leaks (and one of_node
> leak) due to failure to drop the references taken by bus_find_device()
> and friends.
> 
> Note that the final two patches have been compile tested only.
 ...
> v2
>  - hold reference to cpsw-phy-sel device while accessing private data as
>    requested by David. Also update the commit message. (patch 1/4)
>  - add linux-omap on CC where appropriate

Series applied, thanks.
