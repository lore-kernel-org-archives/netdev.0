From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] Bnx2x: remove redundant D0 power state set
Date: Wed, 19 Jun 2013 22:23:25 -0700 (PDT)
Message-ID: <20130619.222325.11404776754498711.davem@davemloft.net>
References: <1371542739-13552-1-git-send-email-wangyijing@huawei.com>
	<979A8436335E3744ADCD3A9F2A2B68A52AC8828E@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangyijing@huawei.com, linux-kernel@vger.kernel.org,
	guohanjun@huawei.com, jiang.liu@huawei.com, eilong@broadcom.com,
	netdev@vger.kernel.org
To: yuvalmin@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AC8828E@SJEXCHMB10.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Tue, 18 Jun 2013 09:37:27 +0000

>> Pci_enable_device() will set device power state to D0,
>> so it's no need to do it again in bnx2x_init_dev().
>> Also remove redundant PM Cap find code, because pci core
>> has been saved the pci device pm cap value.
>> 
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> Cc: Eilon Greenstein <eilong@broadcom.com>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
> [...]
> 
> Acked-by: Yuval Mintz <yuvalmin@broadcom.com>

Applied.
