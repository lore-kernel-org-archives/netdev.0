From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] net: Changes in queue allocation and freeing
Date: Mon, 15 Nov 2010 13:04:43 -0800
Message-ID: <AANLkTimk5iGMdQOB=0xjpVq5Zz9kBSunhmB_RXoGmuZT@mail.gmail.com>
References: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
	<20101115.105822.233710935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:62082 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081Ab0KOVEr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 16:04:47 -0500
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oAFL4jLv010990
	for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 13:04:46 -0800
Received: from gxk25 (gxk25.prod.google.com [10.202.11.25])
	by kpbe16.cbf.corp.google.com with ESMTP id oAFL4gZt007298
	for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 13:04:44 -0800
Received: by gxk25 with SMTP id 25so4135660gxk.22
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 13:04:44 -0800 (PST)
In-Reply-To: <20101115.105822.233710935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 15, 2010 at 10:58 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 9 Nov 2010 12:47:26 -0800 (PST)
>
>> Changes to both RX and TX queue allocation. =A0In both cases allocat=
e
>> in alloc_netdev_mq and free in free_netdev. =A0For RX the reference
>> couting also changed, the device reference count can now be used.
>
> Both applied, with the comment removal added as promised.
>
Thanks.

> I assume you'll spin a new version of the XPS patches
> against this?
>

Yes, those will be forthcoming.

> Thanks!
>
