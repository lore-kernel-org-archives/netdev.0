From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH net-next 1/2] net-next: sundance: Add netconsole logging support
Date: Sat, 17 Aug 2013 11:12:02 +0400
Message-ID: <CAHj3AVkrjo8C802M1zOM-REks9a4V2CU_O=FH+JnK2oSwt_piw@mail.gmail.com>
References: <1376672417-2798-1-git-send-email-kda@linux-powerpc.org>
	<520EB9E9.2020200@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:59858 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab3HQHME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 03:12:04 -0400
Received: by mail-ee0-f54.google.com with SMTP id e53so1242348eek.41
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 00:12:02 -0700 (PDT)
In-Reply-To: <520EB9E9.2020200@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/17/13, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 08/16/2013 09:00 PM, Denis Kirjanov wrote:
>
>     I'd rather name the patch "sundance: add netpoll support". "net-next:"
> shouldn't be there twice definitely.

Right, it was late at night so somehow I added prefix twice.
>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> ---
>>   drivers/net/ethernet/dlink/sundance.c | 14 ++++++++++++++
>>   1 file changed, 14 insertions(+)
>
>> diff --git a/drivers/net/ethernet/dlink/sundance.c
>> b/drivers/net/ethernet/dlink/sundance.c
>> index 50d9c63..2688a84 100644
>> --- a/drivers/net/ethernet/dlink/sundance.c
>> +++ b/drivers/net/ethernet/dlink/sundance.c
> [...]
>> @@ -480,6 +491,9 @@ static const struct net_device_ops netdev_ops = {
>>   	.ndo_change_mtu		= change_mtu,
>>   	.ndo_set_mac_address 	= sundance_set_mac_addr,
>>   	.ndo_validate_addr	= eth_validate_addr,
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +	.ndo_poll_controller = sundance_poll_controller,
>
>     Could you align = here with the reset of initializers?

I'll respin.

Thanks!
>> +#endif
>
> WBR, Sergei
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Regards,
Denis
