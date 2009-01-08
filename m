From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 3/4] r6040: warn about MAC address being unset
Date: Thu, 8 Jan 2009 22:09:52 +0100
Message-ID: <200901082209.53254.florian@openwrt.org>
References: <200901071740.42130.florian@openwrt.org> <20090108.110329.148510077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:34505 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbZAHVJ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:09:59 -0500
Received: by bwz14 with SMTP id 14so28016598bwz.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 13:09:57 -0800 (PST)
In-Reply-To: <20090108.110329.148510077.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Le Thursday 08 January 2009 20:03:29 David Miller, vous avez =E9crit=A0=
:
> Applied.
>
> Even better behavior would be to use a random ethernet address after
> emitting the warning, so that the user still has a usable interface.

Yes, I realised that right after sending the patch ;)

>
> See the random_ether_addr() interface and how many other net drivers
> make use of it in situations nearly identical to this one.

Thanks, will send a patch using this.
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
