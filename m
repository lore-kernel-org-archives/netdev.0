From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH net-next 0/3] fix sw timestamping for non PTP packets
Date: Wed, 28 Jun 2017 16:25:55 -0500
Message-ID: <913d9223-9a76-49f1-b176-9a904e5bf0cd@ti.com>
References: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <m-karicheri2@ti.com>, <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:48007 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbdF1V0D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 17:26:03 -0400
In-Reply-To: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/27/2017 08:58 AM, Ivan Khoronzhuk wrote:
> This series contains several corrections connected with timestamping
> for cpsw and netcp drivers based on same cpts module.
> 
> Based on net/next

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

> 
> Ivan Khoronzhuk (3):
>    net: ethernet: ti: cpsw: move skb timestamp to packet_submit
>    net: ethernet: ti: cpsw: fix sw timestamping for non PTP packets
>    net: ethernet: ti: netcp_ethss: use cpts to check if packet needs
>      timestamping
> 
>   drivers/net/ethernet/ti/cpsw.c        |  6 +++---
>   drivers/net/ethernet/ti/cpts.h        | 16 ++++++++++++++++
>   drivers/net/ethernet/ti/netcp_ethss.c | 18 +-----------------
>   3 files changed, 20 insertions(+), 20 deletions(-)
> 

-- 
regards,
-grygorii
