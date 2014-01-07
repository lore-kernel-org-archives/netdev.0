From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH -next] qlcnic: use vzalloc() instead of
 vmalloc()/memset(0)
Date: Tue, 7 Jan 2014 18:22:51 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E46CF1A67@avmb2.qlogic.org>
References: <CAPgLHd9kdVxAPmxcyZeRpJC7_s8HGyefA+CoYkhhz9pEM2xGKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"Dept-Eng Linux Driver" <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:3307 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752676AbaAGSWz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 13:22:55 -0500
In-Reply-To: <CAPgLHd9kdVxAPmxcyZeRpJC7_s8HGyefA+CoYkhhz9pEM2xGKg@mail.gmail.com>
Content-Language: en-US
Content-ID: <F4C3AE8C529ACC40863E4758034D1913@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 1/7/14 5:48 AM, "Wei Yongjun" <weiyj.lk@gmail.com> wrote:

>From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
>Use vzalloc() instead of vmalloc() and memset(0).
>
>Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>---
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>index b529667..16912e2 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
>@@ -935,11 +935,10 @@ static ssize_t qlcnic_sysfs_read_pci_config(struct
>file *file,
> 		return QL_STATUS_INVALID_PARAM;
> 
> 	pci_info_sz = pci_func_count * sizeof(*pci_info);
>-	pci_info = vmalloc(pci_info_sz);
>+	pci_info = vzalloc(pci_info_sz);
> 	if (!pci_info)
> 		return -ENOMEM;
> 
>-	memset(pci_info, 0, pci_info_sz);
> 	memset(buf, 0, pci_cfg_sz);
> 	pci_cfg = (struct qlcnic_pci_func_cfg *)buf;
> 
>

Thanks,
Jiten
