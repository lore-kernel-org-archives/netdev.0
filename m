From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] usbnet: fix memory leak in usbnet_disconnect()
Date: Mon, 28 Mar 2011 22:01:06 +0200
Message-ID: <4D90E902.2070605@gmail.com>
References: <AANLkTintuq7z45e-Cr8Ma5_Bm+UtnO+Gsysn6A3kv+CZ@mail.gmail.com> <20110327.181107.115927388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39089 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477Ab1C1UBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 16:01:10 -0400
Received: by wwk4 with SMTP id 4so2159848wwk.1
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 13:01:09 -0700 (PDT)
In-Reply-To: <20110327.181107.115927388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/03/2011 03:11, David Miller a =E9crit :
> From: DMITRIY GRUZMAN<xmb836@motorola.com>
> Date: Mon, 21 Mar 2011 16:49:50 -0500
>
>> usb_probe() allocates memory for transfer buffer and urb and this
>> memory was not properly released in usbnet_disconnect().   The issue
>> was found and the fix was recommended by Fu-Lei Tian and Jun-Xiao
>> Chang.
>>
>> Signed-off-by: Dmitriy Gruzman<xmb836@motorola.com>
>
> Your email client corrupted your patch, among other things:
>
>> @@ -210,6 +210,7 @@ static int init_status (struct usbnet *dev, stru=
ct
>> usb_interface *intf)
>
> it chopped up long lines.
>
> Please fix this up, test your setup by emailing the patch to yourself
> and trying to apply what you receive, then try submitting it here
> freshly again.
>
> Thanks.

This nice advice should be inserted into Documentation/SubmittingPatch.

	Nicolas.
