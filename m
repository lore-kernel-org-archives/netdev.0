From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding device in balance-alb mode shows packet loss in kernel
 3.2-rc6
Date: Tue, 27 Dec 2011 20:56:01 +0100
Message-ID: <4EFA22D1.8050807@gmail.com>
References: <E31FB011129F30488D5861F38390491520C52BCC8B@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49676 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1L0Tzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 14:55:46 -0500
Received: by wgbdr13 with SMTP id dr13so21346823wgb.1
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 11:55:45 -0800 (PST)
In-Reply-To: <E31FB011129F30488D5861F38390491520C52BCC8B@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/12/2011 15:31, Narendra_K@Dell.com a =E9crit :
> Hello,
>
> On kernel version 3.2-rc6, when a bonding device is configured in 'ba=
lance-alb' mode,
> ping reported packet losses. By looking at protocol trance, it seemed=
 like the lost
> packets had the destination MAC id of inactive slave.
>

[snip]

Can you provide the output of the following command?

grep . /sys/classs/net/bond0/bonding/*

Thanks,

	Nicolas.
