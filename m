From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: question: Any way to trigger DHCP renewal from kernel code?
Date: Fri, 23 May 2014 17:20:47 +0800
Message-ID: <537F12EF.4010302@gmail.com>
References: <c64a7b76572942fda9acffc25dd76c29@DFM-DB3MBX15-06.exchange.corp.microsoft.com> <537E9B27.8050800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Vlad Yasevich <vyasevich@gmail.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:46158 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaEWJUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 05:20:50 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so3837753pbb.8
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 02:20:50 -0700 (PDT)
In-Reply-To: <537E9B27.8050800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2014 08:49 AM, Vlad Yasevich wrote:
> On 05/22/2014 06:24 PM, Haiyang Zhang wrote:
>> Hi,
>>
>> Our synthetic network driver is notified when the Hyper-V host
>> resume from sleep/hibernation. We need to renew DHCP in this case.
>> I'm looking for a way to trigger DHCP renewal from kernel mode
>> code.
>>
>> Can anyone help me?
> One idea:
>
> Generate a udev event and a udev rule that triggers a renew when
> event is received.
>
> -vlad
Another idea:

crontab, Periodically trigger a renew.

Zhu Yanjun
>
>> Thanks,
>> - Haiyang
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
