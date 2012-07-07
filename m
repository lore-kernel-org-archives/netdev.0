From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question: eth0 and wlan0 traffic load
Date: Fri, 06 Jul 2012 21:16:38 -0700
Message-ID: <4FF7B826.4010007@candelatech.com>
References: <CAF1ivSaY3s-Vjbe7_vziCRCEsaXduug3+2G9R55SUBQ8HPT6hQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45056 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913Ab2GGEQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 00:16:49 -0400
In-Reply-To: <CAF1ivSaY3s-Vjbe7_vziCRCEsaXduug3+2G9R55SUBQ8HPT6hQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/2012 08:28 PM, Lin Ming wrote:
> On Host1
>    eth0: 192.168.1.102
> wlan0: 192.168.1.103
>
> On Host2, scp a file to Host1 via wlan0
> # scp tmp.file 192.168.1.103:/tmp
>
> But ifstat shows all traffic goes to eth0.
> Why does kernel choose eth0 although I use wlan0's address?
> Is this an intended behavior?

You have to be clever with routing rules, arp-filtering, and such
to ensure that works as you want.

Thanks,
Ben

>
>         eth0               wlan0
>   KB/s in  KB/s out   KB/s in  KB/s out
> 11989.26    286.05      0.00      0.00
> 11998.90    286.00      0.00      0.00
>   6910.18    170.63      0.00      0.00
> 10260.05    246.82      0.00      0.00
>   8295.90    202.12      0.00      0.00
> 11979.90    282.41      0.00      0.00
> 11618.39    274.71      0.00      0.00
>   7004.78    170.79      0.00      0.00
> 12003.33    286.21      0.00      0.00
>   7775.28    190.59      0.00      0.00
> 11980.18    280.76      0.00      0.00
> 11998.32    286.29      0.00      0.00
> 11995.61    286.08      0.00      0.00
> 11996.57    285.88      0.00      0.00
>   6938.20    162.98      0.00      0.00
>   6736.30    169.22      0.04      0.00
> 12000.92    284.83      0.00      0.00
> 12005.41    286.13      0.00      0.00
> 12000.58    286.27      0.00      0.00
> 11963.65    284.13      0.00      0.00
> 11935.24    281.32      0.00      0.00
> 12002.83    286.27      0.00      0.00
> 11997.59    285.68      0.00      0.00
>
> Thanks,
> Lin Ming
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
