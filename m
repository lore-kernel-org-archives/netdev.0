From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Tue, 19 Jul 2016 08:40:34 +0200
Message-ID: <CAKfDRXjzgd58kS-MzUsZAsD66VCa5=qyqaLr_eZSm-XphxA7Mw@mail.gmail.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
 <1468846886.2280.6.camel@suse.com> <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
 <1468849802.2280.11.camel@suse.com> <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
 <1468851242.2280.14.camel@suse.com> <CAKfDRXiK82ULw7RnRGdFwzad8NOfnwZN0vqv=08Tf+cNSdyd2g@mail.gmail.com>
 <1468909209.2178.0.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33939 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbcGSGkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 02:40:37 -0400
In-Reply-To: <1468909209.2178.0.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 8:20 AM, Oliver Neukum <oneukum@suse.com> wrote:
>> I had a look at some other drivers, and I think we need to be very
>> careful about making setting a random MAC too generic. For example, we
>> might be unlucky and break the possibly_iphdr()-code/assumption in
>> qmi_wwan.c. And there is probably more code/assumptions like that in
>> the network stack.
>
> In this case please use special cases for usbnet, too.
> We need a quirk.

I guess I can match on the VID/PID in usbnet, but won't it be cleaner
to add a new bind() function (in cdc_ether) which matches the two PIDs
and leave usbnet as is? Or am I misunderstanding how to add this
functionality to usbnet?

-Kristian
