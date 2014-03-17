From: Julius Werner <jwerner@chromium.org>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Mon, 17 Mar 2014 14:53:06 -0700
Message-ID: <CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Grundler <grundler@google.com>,
	Julius Werner <jwerner@chromium.org>,
	netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:37357 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaCQVxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:53:08 -0400
Received: by mail-oa0-f48.google.com with SMTP id m1so6301157oag.21
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 14:53:07 -0700 (PDT)
In-Reply-To: <CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

Any update on the state of this patch? Did it get picked up for merge
somewhere? Do you agree with my suggestion of sticking closer to the
original logic instead of adding that autopm_get(), or do you maybe
want to add some more reviewers to confirm your code? I don't really
care that much which way we choose in the end, I just want to make
sure this bug gets fixed and we don't forget about it.

Thanks,
Julius
