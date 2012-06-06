From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next 2/3] qlcnic: fix unsupported CDRP command error
 message.
Date: Wed, 6 Jun 2012 11:35:07 -0700
Message-ID: <CBF4EF06.320E8%anirban.chakraborty@qlogic.com>
References: <1339006447.13710.6.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:10388
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751634Ab2FFSfe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 14:35:34 -0400
In-Reply-To: <1339006447.13710.6.camel@joe2Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/6/12 11:14 AM, "Joe Perches" <joe@perches.com> wrote:

>On Wed, 2012-06-06 at 13:35 -0400, Anirban Chakraborty wrote:
>> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>> 
>> Add debug messages for FW CDRP command failure.
>
>trivia:
>
>Please be consistent with the use of (preferably _no_) periods
>at the end of logging messages.
>
>$ git grep -E "[^\.]\\\\n\"" drivers/net/ethernet/qlogic/qlcnic/ | wc -l
>187
>$ git grep -E "\.\\\\n\"" drivers/net/ethernet/qlogic/qlcnic/ | wc -l
>22
>
>[]
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
>>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
>[]
>> @@ -53,12 +53,39 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
>>struct qlcnic_cmd_args *cmd)
>>  	rsp = qlcnic_poll_rsp(adapter);
>>  
>>  	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
>> -		dev_err(&pdev->dev, "card response timeout.\n");
>> +		dev_err(&pdev->dev, "CDRP response timeout.\n");
>
>ie: no period necessary.

Thanks for pointing it out. We will not add that period in commit messages
from next time on.

>
>CDRP is kind of an odd acronym.
>Is it for CarD ResPonse?

It stands for FW CommanD ResPonse.

>
>If it is, then I think a lot of the below messages are
>not particularly sensible and the CDRP should be dropped.

Having CDRRP in the message string helps us identify the source of error.
This works well for us in debugging issues.

-Anirban
