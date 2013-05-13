From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH -next] qlcnic: convert list_for_each to entry variant
Date: Mon, 13 May 2013 15:57:12 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4BBBE6@avmb2.qlogic.org>
References: <CAPgLHd_dxz-Nh2MAtEnSBWBrpSoyUBsQaoc2Hvh7CH4hhfNQKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:14047
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751368Ab3EMP5V convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 May 2013 11:57:21 -0400
In-Reply-To: <CAPgLHd_dxz-Nh2MAtEnSBWBrpSoyUBsQaoc2Hvh7CH4hhfNQKA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Wei Yongjun [mailto:weiyj.lk@gmail.com]
> Sent: Monday, May 13, 2013 2:31 PM
> To: Rajesh Borundia; Shahed Shaikh; Jitendra Kalsaria; Sony Chacko
> Cc: yongjun_wei@trendmicro.com.cn; Dept-Eng Linux Driver; netdev
> Subject: [PATCH -next] qlcnic: convert list_for_each to entry variant
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> convert list_for_each() to list_for_each_entry().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 8fb836d..d7d4851 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -311,10 +311,8 @@ int qlcnic_read_mac_addr(struct qlcnic_adapter
> *adapter)  static void qlcnic_delete_adapter_mac(struct qlcnic_adapter
> *adapter)  {
>  	struct qlcnic_mac_list_s *cur;
> -	struct list_head *head;
> 
> -	list_for_each(head, &adapter->mac_list) {
> -		cur = list_entry(head, struct qlcnic_mac_list_s, list);
> +	list_for_each_entry(cur, &adapter->mac_list, list) {
>  		if (!memcmp(adapter->mac_addr, cur->mac_addr,
> ETH_ALEN)) {
>  			qlcnic_sre_macaddr_change(adapter, cur-
> >mac_addr,
>  						  0, QLCNIC_MAC_DEL);
> 

Thanks!

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
