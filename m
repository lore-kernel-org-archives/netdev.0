From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: Re: [PATCH Resend 1/3] net: cdc-phonet: Staticize usbpn_probe
Date: Thu, 19 Sep 2013 12:14:19 +0530
Message-ID: <CAK9yfHx30AH6z+99ZE19PLWb+yBo4C8jaRh1udeZ-pF8cjQVSQ@mail.gmail.com>
References: <1379475001-24505-1-git-send-email-sachin.kamat@linaro.org>
	<20130918.122124.464642242992278820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, remi@remlab.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:63264 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab3ISGoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 02:44:20 -0400
Received: by mail-ob0-f176.google.com with SMTP id uy5so8930707obc.21
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 23:44:19 -0700 (PDT)
In-Reply-To: <20130918.122124.464642242992278820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 September 2013 21:51, David Miller <davem@davemloft.net> wrote:
> From: Sachin Kamat <sachin.kamat@linaro.org>
> Date: Wed, 18 Sep 2013 08:59:59 +0530
>
>> @@ -328,7 +328,8 @@ MODULE_DEVICE_TABLE(usb, usbpn_ids);
>>
>>  static struct usb_driver usbpn_driver;
>>
>> -int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
>> +static int
>> +usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
>
> Please keep it to one line, it's 82 columns which is fine.

OK. Will re-send.

-- 
With warm regards,
Sachin
