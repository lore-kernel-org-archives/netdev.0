From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH series v2] IEEE 802.15.4 MAC layer basic implementation
Date: Mon, 26 Dec 2011 18:57:12 +0100
Message-ID: <4EF8B578.6050201@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-zigbee-devel <linux-zigbee-devel@lists.sourceforge.net>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51517 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab1LZR5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 12:57:00 -0500
Received: by wibhm6 with SMTP id hm6so4491690wib.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 09:56:58 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/12/2011 17:01, Alexander Smirnov a =E9crit :
> Dear David, colleagues,
>
> I'm very sorry for the flood with my previous messages, problems with
> mail client :-(
>
> This is the second version of patch series which adds basic support f=
or
> IEEE 802.15.4 Medium Access Control layer.
>
> The IEEE 802.15.4 Working Group focuses on the standardization of the
> bottom two layers of ISO/OSI protocol stack: Physical (PHY) and MAC.
> The MAC layer provides access control to a shared channel and reliabl=
e
> data delivery.
>
> This series provide only basic features:
>   - interface for drivers registration
>   - RX/TX datapaths
>   - reduced mlme operations
>   - monitor device type support (used by network sniffers, e.g. Wires=
hark)
>   - IEEE 802.15.4 loopback driver
>   - documentation update

Is the word "slave" used by IEEE 802.15.4 or by the kernel part you exp=
and?

I remember a few years ago someone advocating against the usage of the =
word "slave", due to its=20
meaning outside of IT. I know it is used many time in the kernel (in pa=
rticular in bonding), but if=20
people advocate against this usage, we should use "port" instead, if an=
d when possible.

(Yes, I know, I just posted a patch to document the active_slave option=
 for bonding... :-/ ).

	Nicolas.
