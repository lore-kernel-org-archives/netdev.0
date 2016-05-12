From: Harvey Hunt <harvey.hunt@imgtec.com>
Subject: Re: [PATCH net] drivers: net: Don't print unpopulated net_device name
Date: Thu, 12 May 2016 14:27:10 +0100
Message-ID: <573484AE.2040507@imgtec.com>
References: <1462898601-5429-1-git-send-email-harvey.hunt@imgtec.com>
 <20160511.192631.759104843385712307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <robert.jarzmik@free.fr>, <Baohua.Song@csr.com>,
	<marcel@ziswiler.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160511.192631.759104843385712307.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 12/05/16 00:26, David Miller wrote:
> From: Harvey Hunt <harvey.hunt@imgtec.com>
> Date: Tue, 10 May 2016 17:43:21 +0100
>
>> @@ -1686,8 +1686,7 @@ dm9000_probe(struct platform_device *pdev)
>>   	}
>>
>>   	if (!is_valid_ether_addr(ndev->dev_addr)) {
>> -		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
>> -			 "set using ifconfig\n", ndev->name);
>> +		dev_warn(db->dev, "Invalid ethernet MAC address. Please set using ifconfig\n");
>>
>>   		eth_hw_addr_random(ndev);
>>   		mac_src = "random";
>
> If we don't print the netdev name, it's harder for the user to see which
> adapter has the problem.
>
> Therefore, it is better if you save some boolean state into a local variable
> here, then print the warning right after register_netdev().
>
> Likewise for the rest of your changes too.
>

Okay, I'll do that for v2.

Thanks,

Harvey
