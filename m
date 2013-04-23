From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V2 1/5] net/mlx4_core: Add timestamping device
 capability
Date: Tue, 23 Apr 2013 10:01:18 +0300
Message-ID: <517631BE.6020906@mellanox.com>
References: <1366631767-16493-1-git-send-email-amirv@mellanox.com> <1366631767-16493-2-git-send-email-amirv@mellanox.com> <51756F1F.8030903@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:41503 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752048Ab3DWHBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 03:01:25 -0400
In-Reply-To: <51756F1F.8030903@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/04/2013 20:10, Sergei Shtylyov wrote:
> Hello.
> 
> On 04/22/2013 03:56 PM, Amir Vadai wrote:
> 
>> From: Eugenia Emantayev <eugenia@mellanox.com>
>>
>> Add new device capability for timestamping support and query FW to
>> retrieve it.
>>
>> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/fw.c |    7 ++++++-
>>   include/linux/mlx4/device.h             |    3 ++-
>>   2 files changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c
>> b/drivers/net/ethernet/mellanox/mlx4/fw.c
>> index ab470d9..8f394be 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/fw.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
>> @@ -130,7 +130,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev
>> *dev, u64 flags)
>>           [1] = "RSS Toeplitz Hash Function support",
>>           [2] = "RSS XOR Hash Function support",
>>           [3] = "Device manage flow steering support",
>> -        [4] = "Automatic mac reassignment support"
>> +        [4] = "Automatic mac reassignment support",
> 
>    "MAC" perhaps? Although you're only adding a comma...
Will change in V3.

> 
> WBR, Sergei
> 

Thanks,
Amir
