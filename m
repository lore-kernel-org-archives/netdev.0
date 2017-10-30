From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: net: hns: set correct return value
Date: Mon, 30 Oct 2017 09:17:54 +0100
Message-ID: <20171030081753.GG1370@distanz.ch>
References: <1509287732-32172-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>,
        lipeng <lipeng321@huawei.com>, Kejian Yan <yankejian@huawei.com>,
        Lin Yun Sheng <linyunsheng@huawei.com>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1509287732-32172-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-10-29 at 15:35:32 +0100, Pan Bian <bianpan2016@163.com> wrote:
> The function of_parse_phandle() returns a NULL pointer if it cannot
> resolve a phandle property to a device_node pointer. In function
> hns_nic_dev_probe(), its return value is passed to PTR_ERR to extract
> the error code. However, in this case, the extracted error code will
> always be zero, which is unexpected.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

The subject is missing a [PATCH] prefix which causes the patch e.g. to
not show up on patchwork [1]. Care to resend with the proper subject?

[1] https://patchwork.ozlabs.org/project/netdev/list/

Care to resend with the proper subject?

For the patch itself:

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
