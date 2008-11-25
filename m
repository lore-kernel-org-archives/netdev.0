From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Tue, 25 Nov 2008 17:51:10 +0100
Message-ID: <b0438a630811250851p18f5feabx7e744978555fa1d1@mail.gmail.com>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	 <m3fxlksncm.fsf@maximus.localdomain>
	 <b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	 <b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
	 <m3prkl14pf.fsf@maximus.localdomain>
	 <b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
	 <m3tz9wsmut.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:4318 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbYKYQvM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 11:51:12 -0500
Received: by yw-out-2324.google.com with SMTP id 9so27630ywe.1
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 08:51:11 -0800 (PST)
In-Reply-To: <m3tz9wsmut.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2008/11/25 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> I am not quite sure about this. If we do not set the clock_rate as
>> part of the "physical_mode"... where should it be set? As a separate
>> variable?
>
> I think so. In most cases the external clock will be used anyway.
>
OK.

> The truth is the HSS channelized code is quite experimental. It works=
,
> and I actually use it, but I haven't yet decided about the API and
> this is why it isn't still upstream.
>
I understand.

>> Sure... Let me re-do the question. Do you know how MVIP is set if I
>> detect it is needed? And... good idea with the registering of four
>> devices.
>
> The platform code should provide the "mode" (aka topology) =3D "4 * E=
1".
> There is nothing to detect. The driver has to handle 4E1, that's all.
>
I think I do not make me understand myself... The question is: Do you
know which message should I send to the NPE to configure it for MVIP
mode?

I have another question though... It is very basic, but I am mixing thi=
ngs...
- If you have just one source of data, you can use packetized mode
(and it does not care which clock rate you are using...).
- If you have more than one sources of data and are working (for
example) with an E1, you create a channel for each source, and the
driver manages it.
- But... If I want four sources of unstructured data (one for each
"E1" in a 4E1), must I use a channelized mode, or a packetized mode?

Thanks

Miguel =C1ngel
