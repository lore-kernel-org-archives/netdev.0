From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: fix memory leak in usbnet_disconnect()
Date: Sun, 27 Mar 2011 18:11:07 -0700 (PDT)
Message-ID: <20110327.181107.115927388.davem@davemloft.net>
References: <AANLkTintuq7z45e-Cr8Ma5_Bm+UtnO+Gsysn6A3kv+CZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a20612@motorola.com, jxchang@motorola.com
To: xmb836@motorola.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39896
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553Ab1C1BLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:11:45 -0400
In-Reply-To: <AANLkTintuq7z45e-Cr8Ma5_Bm+UtnO+Gsysn6A3kv+CZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: DMITRIY GRUZMAN <xmb836@motorola.com>
Date: Mon, 21 Mar 2011 16:49:50 -0500

> usb_probe() allocates memory for transfer buffer and urb and this
> memory was not properly released in usbnet_disconnect().   The issue
> was found and the fix was recommended by Fu-Lei Tian and Jun-Xiao
> Chang.
> 
> Signed-off-by: Dmitriy Gruzman <xmb836@motorola.com>

Your email client corrupted your patch, among other things:

> @@ -210,6 +210,7 @@ static int init_status (struct usbnet *dev, struct
> usb_interface *intf)

it chopped up long lines.

Please fix this up, test your setup by emailing the patch to yourself
and trying to apply what you receive, then try submitting it here
freshly again.

Thanks.
