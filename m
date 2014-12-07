From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 2/2] rocker: remove swdev mode
Date: Sun, 07 Dec 2014 08:55:54 -0800
Message-ID: <5484869A.6020204@cumulusnetworks.com>
References: <1417935267-6000-3-git-send-email-roopa@cumulusnetworks.com> <20141207081928.GA2215@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:56766 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbaLGQ4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 11:56:00 -0500
In-Reply-To: <20141207081928.GA2215@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/7/14, 12:19 AM, Thomas Graf wrote:
> On 12/06/14 at 10:54pm, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>   drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
>>   include/linux/rtnetlink.h            |    2 +-
>>   net/core/rtnetlink.c                 |   12 +++++++++---
>>   3 files changed, 11 insertions(+), 21 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index fded127..9f1d256 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3755,7 +3739,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>   				      u32 filter_mask)
>>   {
>>   	struct rocker_port *rocker_port = netdev_priv(dev);
>> -	u16 mode = BRIDGE_MODE_SWDEV;
>> +	u16 mode = -1;
>          ^^^
>
> I assume you meant s16
>
yes :(...i thought i had covered all places....missed this 
one...resubmitting ..
