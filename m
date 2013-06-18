From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [PATCH 1/9] Bnx2x: remove redundant D0 power state set
Date: Tue, 18 Jun 2013 09:37:27 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AC8828E@SJEXCHMB10.corp.ad.broadcom.com>
References: <1371542739-13552-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Hanjun Guo" <guohanjun@huawei.com>,
	"jiang.liu@huawei.com" <jiang.liu@huawei.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yijing Wang" <wangyijing@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371542739-13552-1-git-send-email-wangyijing@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Pci_enable_device() will set device power state to D0,
> so it's no need to do it again in bnx2x_init_dev().
> Also remove redundant PM Cap find code, because pci core
> has been saved the pci device pm cap value.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
[...]

Acked-by: Yuval Mintz <yuvalmin@broadcom.com>

Thanks,
Yuval
