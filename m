From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next v1] net: netcp: remove call to netif_carrier_(on/off)
 for MAC to Phy interface
Date: Mon, 27 Apr 2015 13:07:35 -0400
Message-ID: <553E6CD7.9040409@ti.com>
References: <1429902101-2911-1-git-send-email-m-karicheri2@ti.com> <20150425.154856.1696991150241343700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55068 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932363AbbD0RHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:07:31 -0400
In-Reply-To: <20150425.154856.1696991150241343700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2015 03:48 PM, David Miller wrote:
> From: Murali Karicheri<m-karicheri2@ti.com>
> Date: Fri, 24 Apr 2015 15:01:41 -0400
>
>> Currently when interface type is MAC to Phy, netif_carrier_(on/off)
>> is called which is not needed as Phy lib already updates the carrier
>> status to net stack. This is needed only for other interface types
>>
>> Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
>
> net-next is not open for submissions yet
David,

Do I need to re-submit this patch when the net-next gets opened for 
this? This is essentially a bug fix and can be applied to current 
version (v4.1) as well. The reason I thought of adding this to net-next 
is because the DTS patch set for enabling network driver on K2 devices
is queued for v4.2. But this has no dependency on this DTS patch and
hence can be applied to v4.1 as well if you are fine with it.

Regards,
-- 
Murali Karicheri
Linux Kernel, Texas Instruments
