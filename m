From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] usbnet: use netif_tx_wake_queue instead of
 netif_start_queue
Date: Fri, 16 Mar 2012 22:50:49 -0700 (PDT)
Message-ID: <20120316.225049.279188750788151013.davem@davemloft.net>
References: <1331733624-23266-1-git-send-email-alexey.orishko@stericsson.com>
	<201203151805.09136.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexey.orishko@gmail.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	alexey.orishko@stericsson.com
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab2CQFvE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 01:51:04 -0400
In-Reply-To: <201203151805.09136.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Neukum <oneukum@suse.de>
Date: Thu, 15 Mar 2012 18:05:09 +0100

> Am Mittwoch, 14. M=E4rz 2012, 15:00:24 schrieb Alexey Orishko:
>> If host is going to autosuspend function with two interfaces and
>> if IP packet has arrived in-between of two usbnet_suspend() callback=
s,
>> i.e usbnet_resume() is called in-between, tx data flow is stopped.
>> When autosuspend timer expires and device is put to autosuspend
>> again, tx queue is waked up and data can be sent again.
>> This behavior might be repeated several times in a row.
>>=20
>> Tested on Intel/ARM.
>>=20
>> Reviewed-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
>> Tested-by: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
>> Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>
> Acked-by: Oliver Neukum <oneukum@suse.de>

Applied, thanks.
