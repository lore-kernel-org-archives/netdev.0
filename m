From: George Cherian <george.cherian@ti.com>
Subject: Re: [PATCH v2 2/3] net: davinci_mdio: Convert pr_err() to dev_err()
 call
Date: Fri, 9 May 2014 10:45:17 +0530
Message-ID: <536C6465.6060907@ti.com>
References: <1399542652-14900-1-git-send-email-george.cherian@ti.com> <1399542652-14900-3-git-send-email-george.cherian@ti.com> <B5657A6538887040AD3A81F1008BEC63AD20DC@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"balbi@ti.com" <balbi@ti.com>,
	"zonque@gmail.com" <zonque@gmail.com>,
	"mpa@pengutronix.de" <mpa@pengutronix.de>,
	"tklauser@distanz.ch" <tklauser@distanz.ch>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63AD20DC@avmb3.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/8/2014 10:20 PM, Yuval Mintz wrote:
>> Also, Convert kzalloc to devm_kzalloc.
> Looks like you should remove this part of the comment.
Ah... Missed to update the commit log after rebasing patch to net-next.
>> Signed-off-by: George Cherian <george.cherian@ti.com>
>> Reviewed-by: Felipe Balbi <balbi@ti.com>
>> ---
>>   drivers/net/ethernet/ti/davinci_mdio.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c
>> b/drivers/net/ethernet/ti/davinci_mdio.c
>> index 34e97ec..735dc53 100644
>> --- a/drivers/net/ethernet/ti/davinci_mdio.c
>> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
>> @@ -303,7 +303,7 @@ static int davinci_mdio_probe_dt(struct
>> mdio_platform_data *data,
>>                return -EINVAL;
>>
>>        if (of_property_read_u32(node, "bus_freq", &prop)) {
>> -             pr_err("Missing bus_freq property in the DT.\n");
>> +             dev_err(&pdev->dev, "Missing bus_freq property in the DT.\n");
>>                return -EINVAL;
>>        }
>>        data->bus_freq = prop;
> ________________________________
>
> This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.


-- 
-George
