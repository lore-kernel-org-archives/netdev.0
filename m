From: Yanjun Zhu <yanjun.zhu@oracle.com>
Subject: Re: [PATCH 1/1] r8169: fix the typo
Date: Fri, 30 Dec 2016 10:19:12 +0800
Message-ID: <5865C420.8030200@oracle.com>
References: <1482981062-6889-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: nic_swsd@realtek.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41742 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbcL3CTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 21:19:02 -0500
In-Reply-To: <1482981062-6889-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please comment on this patch.

Zhu Yanjun

On 2016/12/29 11:11, Zhu Yanjun wrote:
> >From the realtek data sheet, the PID0 should be bit 0.
>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>   drivers/net/ethernet/realtek/r8169.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 44389c9..8f1623b 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -696,7 +696,7 @@ enum rtl_tx_desc_bit_1 {
>   enum rtl_rx_desc_bit {
>   	/* Rx private */
>   	PID1		= (1 << 18), /* Protocol ID bit 1/2 */
> -	PID0		= (1 << 17), /* Protocol ID bit 2/2 */
> +	PID0		= (1 << 17), /* Protocol ID bit 0/2 */
>   
>   #define RxProtoUDP	(PID1)
>   #define RxProtoTCP	(PID0)
