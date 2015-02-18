From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: Setting RPS affinities from network driver
Date: Wed, 18 Feb 2015 21:17:20 +0530
Message-ID: <CA+sq2CdYSg4NTnyLOMGyF1bmfr0+h+9UJyjJGO2hKEcq4rED8A@mail.gmail.com>
References: <CA+sq2CeC89YfaTM18JR9dFOoNAbohGk=gFXSkM_4q2oySB12GA@mail.gmail.com>
	<CA+mtBx9qHdEeXmEGbbWSr_OL3aAQJ37eTbC0mUY_XrTNoZ6iXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:40197 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbBRPrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 10:47:22 -0500
Received: by mail-wg0-f48.google.com with SMTP id l18so1934457wgh.7
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 07:47:21 -0800 (PST)
In-Reply-To: <CA+mtBx9qHdEeXmEGbbWSr_OL3aAQJ37eTbC0mUY_XrTNoZ6iXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Tom,

Will try to implement something like a library function which can be used
by any driver.

Regards,
Sunil.

On Wed, Feb 18, 2015 at 9:14 PM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Feb 17, 2015 at 10:16 PM, Sunil Kovvuri <sunil.kovvuri@gmail.com> wrote:
>> Hi,
>>
>> I am writing a network driver for a multicore SOC with a on-board
>> network interface and would like to set RPS affinities from driver by
>> default. So that the network performance is good with whatever driver
>> supplied. Ofcourse these can be further adjusted from userspace
>> anyways.
>>
>> Is there a way to set RPS settings from driver itself ?
>> The only issue i am seeing is while setting 'rps_needed' key.
>>
> There is nothing to prevent this, but it would be really cool to make
> this into a library function that drivers can call to initialize RPS
> in some sane way (you might want to look at cpu_rmap).
>
>> static_key_slow_inc(&rps_needed);
>>
>> Currently this is not exported, so having issues while compiling
>> driver as module.
>>
>> If i export this symbol, will it be acceptable ?
>>
> Seems okay to me.
>
> Thanks,
> Tom
>
>>
>> Thanks,
>> Sunil.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
