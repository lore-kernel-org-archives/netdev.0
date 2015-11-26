From: Salil Mehta <salil.mehta@huawei.com>
Subject: Re: [PATCH V3 net-next 3/5] net:hns: Add Hip06 "TSO(TCP Segment Offload)"
 support HNS Driver
Date: Thu, 26 Nov 2015 08:19:26 +0000
Message-ID: <5656C08E.2010105__7794.79187117449$1448526116$gmane$org@huawei.com>
References: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com> <1447966706-16219-4-git-send-email-salil.mehta@huawei.com> <CO2PR11MB00885067453FB6462178765497180@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
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
Received: from szxga01-in.huawei.com ([58.251.152.64]:57460 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbbKZIUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 03:20:47 -0500
In-Reply-To: <CO2PR11MB00885067453FB6462178765497180@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/22/2015 8:49 AM, Yuval Mintz wrote:
>> +static void hns_ae_set_tso_stats(struct hnae_handle *handle, int
>> +enable) {
>> +	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
>> +
>> +	hns_ppe_set_tso_enable(ppe_cb, enable); }
> Style issues?
I could not see the code style issue menioned above in earlier submitted 
patch. Looks like I am misssing something here!

+static void hns_ae_set_tso_stats(struct hnae_handle *handle, int enable)
+{
+	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
+
+	hns_ppe_set_tso_enable(ppe_cb, enable);
+}
+

>
>> +void hns_ppe_set_tso_enable(struct hns_ppe_cb *ppe_cb, u32 value) {
>> +	dsaf_set_dev_bit(ppe_cb, PPEV2_CFG_TSO_EN_REG, 0, !!value); }
>> +
> Likewise
Same in above case. Hope I am not missing anything.

  #include "hns_dsaf_ppe.h"
  
+void hns_ppe_set_tso_enable(struct hns_ppe_cb *ppe_cb, u32 value)
+{
+	dsaf_set_dev_bit(ppe_cb, PPEV2_CFG_TSO_EN_REG, 0, !!value);
+}
+
