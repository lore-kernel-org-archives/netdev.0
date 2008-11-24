From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Mon, 24 Nov 2008 11:03:29 +0100
Message-ID: <b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	 <m3fxlksncm.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:35245 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbYKXKDb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 05:03:31 -0500
Received: by yx-out-2324.google.com with SMTP id 8so791232yxm.1
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 02:03:30 -0800 (PST)
In-Reply-To: <m3fxlksncm.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2008/11/21 Krzysztof Halasa <khc@pm.waw.pl>:
> Hi,
>
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> I am interested in modifying ixp4xx_hss so that 4*32 channels can be
>> used for each hss device.
>
> I assume you mean 4 multiplexed E1 (with an external multiplexer/fram=
er).
>

Sure. Sorry for not having stated it properly.

>> My first option is to modify the "defines" placed in the driver, but=
 I
>> wonder if it would be useful to modify hss_plat_info to set this kin=
d
>> of info.
>
> I think we should add some "physical mode" parameter - single channel
> (such as E1, T1 etc), 4 * E1, and any other (4 * T1 which is IIRC
> special) when needed.
>

This is a great idea. Lots of parameters are related, so setting this
"physical mode" should be enough to configure the rest. I will try to
prepare a simple patch in order to comment if the ideas are correct.

> It can go into hss_plat_info - a fixed(?) HSS port property.

Yes... I think it could be enough to make it a fixed property at the
moment. Maybe it could be added to sysfs in the future.

Miguel =C1ngel =C1lvarez
