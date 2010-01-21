From: Szilveszter Ordog <slipszi@gmail.com>
Subject: Re: Problems with tg3 driver after lowering the MTU
Date: Thu, 21 Jan 2010 16:42:07 +0100
Message-ID: <ac67d9131001210742x7bb6af87o546007707c412835@mail.gmail.com>
References: <ac67d9131001210721q37a6883eg85430f9564d8e007@mail.gmail.com>
	 <1264087643.2794.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:42111 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab0AUPmK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 10:42:10 -0500
Received: by fxm20 with SMTP id 20so120235fxm.1
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 07:42:08 -0800 (PST)
In-Reply-To: <1264087643.2794.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 16:27, Ben Hutchings <bhutchings@solarflare.com=
> wrote:
> On Thu, 2010-01-21 at 16:21 +0100, Szilveszter Ordog wrote:
>> After the MTU is lowered (e.g. to 1420) on a tg3-driven interface,
>> received packets larger than that (e.g. 1500 bytes) are silently
>> discarded by the driver. Therefore the system doesn't send ICMP
>> fragmentation-needed packets and the other side doesn't detect this
>> condition.
>>
>> Is this a known bug?
>
> I don't believe this a bug. =A0Within a local network, MTU should be =
set
> the same for all interfaces. =A0Routers that connect networks with
> different MTUs will generate the fragmentation-needed message as
> appropriate.

Other drivers do not behave like that. Most of them always allow
packets smaller than 1500 bytes. That is why I think that this is a
bug.

slipszi
