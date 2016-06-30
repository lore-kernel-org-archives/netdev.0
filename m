From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: [PATCH 1/1] qlcnic: add wmb() call in transmit data path.
Date: Thu, 30 Jun 2016 17:32:31 +0200
Message-ID: <57753B8F.9020302@marvell.com>
References: <1467237094-23088-1-git-send-email-sony.chacko@qlogic.com>
 <1467237094-23088-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:22823 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932072AbcF3Pck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:32:40 -0400
In-Reply-To: <1467237094-23088-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 29.06.2016 23:51, Sony Chacko wrote:

> +	/* Ensure writes are complete before HW fetches Tx descriptors */
> +	wmb();
>   	qlcnic_update_cmd_producer(tx_ring);
>
>   	return NETDEV_TX_OK;
>

Would not an mmiowb be more appropriate in this case?

Regards,
Lino  
