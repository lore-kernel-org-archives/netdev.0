From: Daode Huang <huangdaode@hisilicon.com>
Subject: Re: [PATCH V2 net 0/6] net: hns: hns driver updates
Date: Tue, 15 Mar 2016 09:56:02 +0800
Message-ID: <56E76BB2.5060203@hisilicon.com>
References: <1457687446-109867-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457687446-109867-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Could you please help me to review this patch set?
I am so sorry to send the patches in parallel to you, which increases 
you workload,
So next time we will pay more attention to it,  and learn more about 
kernel patch submitting.
Thanks.

MBR, Daode

On 2016/3/11 17:10, Daode Huang wrote:
> Hi Dave,
>
> This patch series are hisilicon network driver bug fix.
> please merge them to the net repo.
> Thanks
>
> Daode Huang
> ---
> changlog
> v2: some minor change according to
>      MBR Sergei <sergei.shtylyov@cogentembedded.com> in
>      [patch 3/6] [patch 4/6].
>
> v1: initial version.
>
> Daode Huang (6):
>    net: hns: bug fix about the overflow of mss
>    net: hns: fixes the hw interrupt bug in using napi
>    net: hns: fixed portid bug in sending manage pkt
>    net: hns: adds uc match for debug port
>    net: hns: fixed service-ges setting MAC-addr bug
>    net: hns: bug fix of getting hilink status
>
>   drivers/net/ethernet/hisilicon/hns/hnae.h          |  3 ++
>   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  1 +
>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 29 +++++++++++----
>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 41 ++++++++++++----------
>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  4 +++
>   drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 32 +++++++++--------
>   6 files changed, 70 insertions(+), 40 deletions(-)
>
