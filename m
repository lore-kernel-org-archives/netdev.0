From: Hans Wennborg <hans@hanshq.net>
Subject: Re: [PATCH 1/1] cris: fix %d confusingly prefixed with 0x in format
 string
Date: Sat, 02 Aug 2014 18:19:19 -0700
Message-ID: <53DD8E17.1@hanshq.net>
References: <1407018043-648-1-git-send-email-hans@hanshq.net> <1407026806.1835.21.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: starvik@axis.com, linux-cris-kernel@axis.com,
	linux-kernel@vger.kernel.org,
	kernel-janitors <kernel-janitors@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	devel <devel@driverdev.osuosl.org>, linux-cifs@vger.kernel.org,
	alsa-devel@alsa-project.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407026806.1835.21.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/02/2014 05:46 PM, Joe Perches wrote:
> On Sat, 2014-08-02 at 15:20 -0700, Hans Wennborg wrote:
>> Signed-off-by: Hans Wennborg <hans@hanshq.net>
>> ---
>>   arch/cris/arch-v32/drivers/cryptocop.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/arch/cris/arch-v32/drivers/cryptocop.c b/arch/cris/arch-v32/drivers/cryptocop.c
> []
>> @@ -3155,7 +3155,7 @@ static void print_dma_descriptors(struct cryptocop_int_operation *iop)
>>   	printk("print_dma_descriptors start\n");
>>
>>   	printk("iop:\n");
>> -	printk("\tsid: 0x%lld\n", iop->sid);
>> +	printk("\tsid: 0x%llx\n", iop->sid);
>>
>>   	printk("\tcdesc_out: 0x%p\n", iop->cdesc_out);
>>   	printk("\tcdesc_in: 0x%p\n", iop->cdesc_in);
>
> Thanks.
>
> This is a surprisingly common error:
>
> $ /usr/bin/git grep -P '0x\%(?!ull\b|ul\b|u\b|lu\b|llu\b|llux\b|lux\b|lx\b|lluX\b|luX\b|lX\b)[ul]*[ud]'
[...]

Yes, I have a patch for a bunch of these, but I figured it would be 
easier to get it merged if I split it up. (Complete kernel newbie here.)

  - Hans
