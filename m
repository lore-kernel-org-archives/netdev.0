From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Fri, 21 Nov 2008 23:52:57 +0100
Message-ID: <m3fxlksncm.fsf@maximus.localdomain>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43422 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbYKUWxA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 17:53:00 -0500
In-Reply-To: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Wed\, 19 Nov
 2008 12\:17\:56 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> I am interested in modifying ixp4xx_hss so that 4*32 channels can be
> used for each hss device.

I assume you mean 4 multiplexed E1 (with an external multiplexer/framer=
).

> My first option is to modify the "defines" placed in the driver, but =
I
> wonder if it would be useful to modify hss_plat_info to set this kind
> of info.

I think we should add some "physical mode" parameter - single channel
(such as E1, T1 etc), 4 * E1, and any other (4 * T1 which is IIRC
special) when needed.

It can go into hss_plat_info - a fixed(?) HSS port property.
--=20
Krzysztof Halasa
