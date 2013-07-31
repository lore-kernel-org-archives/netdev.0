From: Ming Lei <ming.lei@canonical.com>
Subject: Re: issues with commit usbnet: mcs7830: apply usbnet_link_change
Date: Wed, 31 Jul 2013 23:57:12 +0800
Message-ID: <CACVXFVN3z8Hd4W_T+7XLvjFb4RmskzgHCAeoGsBvOeVPHE-J4A@mail.gmail.com>
References: <51F8DF64.4030108@schmalmack.net>
	<CACVXFVMwbCjcfeSeD907FDRoqkdN6YDYZ5mxt36ZZceenK8EGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: Till Schmalmack <till@schmalmack.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34634 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756388Ab3GaP5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:57:14 -0400
In-Reply-To: <CACVXFVMwbCjcfeSeD907FDRoqkdN6YDYZ5mxt36ZZceenK8EGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 11:49 PM, Ming Lei <ming.lei@canonical.com> wrote:
> On Wed, Jul 31, 2013 at 5:56 PM, Till Schmalmack <till@schmalmack.net> wrote:
>> Hello Ming,
>>
>> I am experiencing issues with the usbnet commits you did for the 3.10
>> kernel, in particular with
>>
>> 4be74c13 usbnet: mcs7830: apply usbnet_link_change
>>
>> I filed this bug
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=60662
>
> Thanks for the report.
>
> Looks you didn't provide any debug info, could you apply the attachment
> patch and post the 'dmesg' info when you reproduce the bug.

Also I am wondering the commit 4be74c13(usbnet: mcs7830: apply
usbnet_link_change) may cause the regression.

If you look at commit 4be74c13(usbnet: mcs7830: apply usbnet_link_change)
and commit ac64995da(usbnet: introduce usbnet_link_change API),
you may find basically no real code changes on msc7830 drivers, and only
the below code is moved into usbnet_link_change() from mcs7830_status, isn't it?

       if (link)
               netif_carrier_on(dev->net);
       else
               netif_carrier_off(dev->net);



Thanks,
--
Ming Lei
