From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/2] drivers: net: cpsw: Add helper functions for VLAN
 ALE implementation
Date: Wed, 30 Jan 2013 09:47:11 +0530
Message-ID: <51089EC7.5070205@ti.com>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com> <1359403945-28585-2-git-send-email-mugunthanvnm@ti.com> <51085D6C.4050102@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:40552 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175Ab3A3ERr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 23:17:47 -0500
In-Reply-To: <51085D6C.4050102@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/2013 5:08 AM, Cyril Chemparathy wrote:
> On 01/28/2013 03:12 PM, Mugunthan V N wrote:
>> Add helper functions for VLAN ALE implementations for Add, Delete
>> Dump VLAN related ALE entries
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>> ---
>>   drivers/net/ethernet/ti/cpsw_ale.c |  172 
>> ++++++++++++++++++++++++++++++++++--
>>   drivers/net/ethernet/ti/cpsw_ale.h |   11 +++
>>   2 files changed, 178 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw_ale.c 
>> b/drivers/net/ethernet/ti/cpsw_ale.c
>> index 0e9ccc2..0d7a60a 100644
>> --- a/drivers/net/ethernet/ti/cpsw_ale.c
>> +++ b/drivers/net/ethernet/ti/cpsw_ale.c
>
> [...]
>
>> +int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int 
>> untag,
>> +              int reg_mcast, int unreg_mcast)
>
> [...]
>
>> +int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port)
>
> [...]
>
>> +int cpsw_ale_vlan_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
>> +                int flags, u16 vid)
>
> [...]
>
>> +int cpsw_ale_vlan_del_ucast(struct cpsw_ale *ale, u8 *addr, int 
>> port, u16 vid)
>
> [...]
>
>> +int cpsw_ale_vlan_add_mcast(struct cpsw_ale *ale, u8 *addr,
>> +        int port_mask, u16 vid, int super, int mcast_state)
>
> [...]
>
>> +int cpsw_ale_vlan_del_mcast(struct cpsw_ale *ale, u8 *addr,
>> +                int port_mask, u16 vid)
>
> Are the VLAN and non-VLAN variants different enough to justify 
> separate implementations for all these functions?  Could we collapse 
> these by generalizing the original to take an optional vlan argument 
> instead?
>
> Thanks
> -- Cyril.
Since vid is u16, any value to vid is valid, so only i have proposed new 
api for vlan.
add vlan and delete vlan has to be seperate vlan since these are new 
apis. Will merge
other api to existing api with additional vlan parameter.

Regards
Mugunthan V N
