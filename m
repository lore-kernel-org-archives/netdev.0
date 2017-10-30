From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net: hns: set correct return value
Date: Mon, 30 Oct 2017 10:29:41 +0100
Message-ID: <20171030092937.GH1370@distanz.ch>
References: <1509353401-2699-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>,
        lipeng <lipeng321@huawei.com>,
        Lin Yun Sheng <linyunsheng@huawei.com>,
        Kejian Yan <yankejian@huawei.com>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:54882 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752268AbdJ3J3o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 05:29:44 -0400
Content-Disposition: inline
In-Reply-To: <1509353401-2699-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-30 at 09:50:01 +0100, Pan Bian <bianpan2016@163.com> wrote:
> The function of_parse_phandle() returns a NULL pointer if it cannot
> resolve a phandle property to a device_node pointer. In function
> hns_nic_dev_probe(), its return value is passed to PTR_ERR to extract
> the error code. However, in this case, the extracted error code will
> always be zero, which is unexpected.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
