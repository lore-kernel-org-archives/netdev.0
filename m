From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] can: fix oops caused by wrong rtnl dellink usage
Date: Thu, 23 Jun 2016 16:09:00 +0300
Message-ID: <f4b685f9-a2ad-d3cc-1204-f457705467df@cogentembedded.com>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
 <1466673741-23115-3-git-send-email-mkl@pengutronix.de>
 <e092c3e9-56f3-f765-a9ef-89697ec46e16@cogentembedded.com>
 <0e51107f-a381-6c94-0079-d0ed415d8bcc@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, stable@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <0e51107f-a381-6c94-0079-d0ed415d8bcc@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/23/2016 4:01 PM, Oliver Hartkopp wrote:

>>> From: Oliver Hartkopp <socketcan@hartkopp.net>
>>>
>>> For 'real' hardware CAN devices the netlink interface is used to set CAN
>>> specific communication parameters. Real CAN hardware can not be
>>> created nor
>>> removed with the ip tool ...
>>>
>>> This patch adds a private dellink function for the CAN device driver
>>> interface
>>> that does just nothing.
>>>
>>> It's a follow up to commit 993e6f2fd ("can: fix oops caused by wrong rtnl
>>> newlink usage") but for dellink.
>>>
>>> Reported-by: ajneu <ajneu1@gmail.com>
>>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>>> Cc: <stable@vger.kernel.org>
>>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>>> ---
>>>  drivers/net/can/dev.c | 6 ++++++
>>>  1 file changed, 6 insertions(+)
>>>
>>> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
>>> index 348dd5001fa4..ad535a854e5c 100644
>>> --- a/drivers/net/can/dev.c
>>> +++ b/drivers/net/can/dev.c
>>> @@ -1011,6 +1011,11 @@ static int can_newlink(struct net *src_net,
>>> struct net_device *dev,
>>>      return -EOPNOTSUPP;
>>>  }
>>>
>>> +static void can_dellink(struct net_device *dev, struct list_head *head)
>>> +{
>>> +    return;
>>
>>    Why?
>>
>
> http://marc.info/?l=linux-can&m=146651600421205&w=2
>
> The same reason as for commit 993e6f2fd.

    I was asking just about the useless *return* statement...

> Regards,
> Oliver

MBR, Sergei

