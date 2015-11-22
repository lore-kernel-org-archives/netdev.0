From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH V3 net-next 3/5] net:hns: Add Hip06 "TSO(TCP Segment
 Offload)" support HNS Driver
Date: Sun, 22 Nov 2015 08:49:49 +0000
Message-ID: <CO2PR11MB00885067453FB6462178765497180@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com>
 <1447966706-16219-4-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Salil Mehta <salil.mehta@huawei.com>,
	David Miller <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"catalin.marinas@arm.com" <catalin.marinas@arm.com>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
	"yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
	"dingtianhong@huawei.com" <dingtianhong@huawei.com>,
	"zhangfei.gao@linaro.org" <zhangfei.gao@linaro.org>,
	"huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
	"kenneth-lee-2012@foxmail.com" <kenneth-lee-2012@foxmail.com>,
	"mehta.salil.lnk@gmail.com" <mehta.sal
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0108.outbound.protection.outlook.com ([207.46.100.108]:47136
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750778AbbKVIty convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 03:49:54 -0500
In-Reply-To: <1447966706-16219-4-git-send-email-salil.mehta@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void hns_ae_set_tso_stats(struct hnae_handle *handle, int
> +enable) {
> +	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
> +
> +	hns_ppe_set_tso_enable(ppe_cb, enable); }

Style issues?

> +void hns_ppe_set_tso_enable(struct hns_ppe_cb *ppe_cb, u32 value) {
> +	dsaf_set_dev_bit(ppe_cb, PPEV2_CFG_TSO_EN_REG, 0, !!value); }
> +

Likewise
