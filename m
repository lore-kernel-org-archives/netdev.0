From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hns: set correct return value
Date: Wed, 01 Nov 2017 12:18:12 +0900 (KST)
Message-ID: <20171101.121812.969003043230573555.davem@davemloft.net>
References: <1509353401-2699-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        lipeng321@huawei.com, linyunsheng@huawei.com, yankejian@huawei.com,
        tklauser@distanz.ch, arnd@arndb.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509353401-2699-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>
Date: Mon, 30 Oct 2017 16:50:01 +0800

> The function of_parse_phandle() returns a NULL pointer if it cannot
> resolve a phandle property to a device_node pointer. In function
> hns_nic_dev_probe(), its return value is passed to PTR_ERR to extract
> the error code. However, in this case, the extracted error code will
> always be zero, which is unexpected.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
