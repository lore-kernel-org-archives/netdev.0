From: Barry Song <21cnbao@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 18:05:56 +0800
Message-ID: <3c17e3570912100205mc129fb9kd20050c8c2cd8e70@mail.gmail.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>
	<4B20BB36.50509@grandegger.com> <8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, davem@davemloft.net,
	"H.J. Oertel" <oe@port.de>, netdev@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:52260 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778AbZLJKGP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:06:15 -0500
Received: by ywh6 with SMTP id 6so6955836ywh.4
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 02:06:21 -0800 (PST)
In-Reply-To: <8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 6:04 PM, Mike Frysinger <vapier.adi@gmail.com> =
wrote:
> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>> Barry Song wrote:
>>> +#include <linux/module.h>
>>> +#include <linux/init.h>
>>> +#include <linux/kernel.h>
>>> +#include <linux/types.h>
>>
>> I think you don't need "types.h" as the code no longer uses "uint*_t=
".
>
> linux/types.h declares all types, like u* which this driver still use=
s
>
>> Well, I'm still not a friend of the following inline functions,
>> especially the *one-liners* which are called just *once*. With the u=
sage
>> of structs they seem even more useless.
>
> seems like it would make more sense to not even use the read/write
> functions either. =C2=A0just declare the regs as volatile and assign/=
read
> the struct directly.
volatile will cause check patch warning in fact.

> -mike
>
