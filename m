From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Thu, 14 Oct 2010 11:17:58 -0700
Message-ID: <AANLkTi=tTFEgabpQwnzNb4nA6w8NqWQcVLO-9SL8V=9x@mail.gmail.com>
References: <AANLkTi=NvnPov_=KQJz2uXt1R-ep4oahDF0J=3HwhGzG@mail.gmail.com>
	<1286860560.30423.186.camel@edumazet-laptop>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE4282DD@SJEXCHCCR02.corp.ad.broadcom.com>
	<20101014.103914.193713537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladz@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mchan@broadcom.com, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:5834 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871Ab0JNSSE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 14:18:04 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o9EII1UM031992
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 11:18:02 -0700
Received: from pva4 (pva4.prod.google.com [10.241.209.4])
	by hpaq6.eem.corp.google.com with ESMTP id o9EIHxVp002416
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 11:18:00 -0700
Received: by pva4 with SMTP id 4so1633591pva.24
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 11:17:59 -0700 (PDT)
In-Reply-To: <20101014.103914.193713537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 14, 2010 at 10:39 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Tue, 12 Oct 2010 02:12:41 -0700
>
>> Dave, if it can wait till tomorrow, I'd like to ask u to wait for Ei=
lon's
>> final ACK.
>
> Ok, but it is two days later now :-)

If the netdev_alloc_skb is reverted to do local node allocation as
Eric suggested, then this patch against bnx2x (and presumably similar
changes to other drivers) is no longer needed.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
