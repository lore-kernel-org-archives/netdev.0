From: Grant Grundler <grundler@google.com>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Mon, 17 Mar 2014 15:02:39 -0700
Message-ID: <CANEJEGv7Y=Ukxk85Kk4ENrN7sWr7nmQxHEWssBqDQf0_1t8rrg@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	<CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	<1395093343.3961.2.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julius Werner <jwerner@chromium.org>,
	netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:52238 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbaCQWCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 18:02:40 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so6201478obc.15
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 15:02:40 -0700 (PDT)
In-Reply-To: <1395093343.3961.2.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 2:55 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Mon, 2014-03-17 at 14:53 -0700, Julius Werner wrote:
>> Hi Oliver,
>>
>> Any update on the state of this patch? Did it get picked up for merge
>> somewhere? Do you agree with my suggestion of sticking closer to the
>> original logic instead of adding that autopm_get(), or do you maybe
>> want to add some more reviewers to confirm your code? I don't really
>> care that much which way we choose in the end, I just want to make
>> sure this bug gets fixed and we don't forget about it.
>
> I am hping for the reporter of the original bug to test it.

Ok. I didn't realize I was part of the dependency chain here. :)
It seemed "obvious" to me once Julius described the race.

I'll try it on the offending system but fear I will run into some other problem.

cheers,
grant

>
>         Regards
>                 Oliver
>
>
