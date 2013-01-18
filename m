From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix wrong length of mac address
Date: Fri, 18 Jan 2013 14:36:24 -0500 (EST)
Message-ID: <20130118.143624.1891658456904822247.davem@davemloft.net>
References: <1358495514-18047-1-git-send-email-kongjianjun@gmail.com>
	<20130118083031.GA2303@ppwaskie-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kongjianjun@gmail.com, kys@microsoft.com, haiyangz@microsoft.com,
	netdev@vger.kernel.org, devel@linuxdriverproject.org
To: WaskiewiczJr@ppwaskie-mobl2
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:36:26 -0500
In-Reply-To: <20130118083031.GA2303@ppwaskie-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <WaskiewiczJr@ppwaskie-mobl2>
Date: Fri, 18 Jan 2013 00:30:32 -0800

> On Fri, Jan 18, 2013 at 03:51:54PM +0800, Amos Kong wrote:
>> Typo, it should be ETH_ALEN.
>> 
>> Signed-off-by: Amos Kong <kongjianjun@gmail.com>
>> ---
>> v2: update commitlog, fix cc list
>> ---
>>  drivers/net/hyperv/netvsc_drv.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
>> index f825a62..8264f0e 100644
>> --- a/drivers/net/hyperv/netvsc_drv.c
>> +++ b/drivers/net/hyperv/netvsc_drv.c
>> @@ -349,7 +349,7 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
>>  	struct net_device_context *ndevctx = netdev_priv(ndev);
>>  	struct hv_device *hdev =  ndevctx->device_ctx;
>>  	struct sockaddr *addr = p;
>> -	char save_adr[14];
>> +	char save_adr[ETH_ALEN];
>>  	unsigned char save_aatype;
>>  	int err;
> 
> While you're at it, you should also update drivers/net/hyperv/hyperv_net.h
> to also fix the mac_adr definition in struct netvsc_device_info:
> 
> struct netvsc_device_info {
>>>>     unsigned char mac_adr[6];

Agreed.
