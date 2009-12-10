From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 05:04:42 -0500
Message-ID: <8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>
	<4B20BB36.50509@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Barry Song <21cnbao@gmail.com>, socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, davem@davemloft.net,
	"H.J. Oertel" <oe@port.de>, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:59699 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbZLJKEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:04:55 -0500
Received: by gxk4 with SMTP id 4so12164362gxk.8
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 02:05:02 -0800 (PST)
In-Reply-To: <4B20BB36.50509@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
> Barry Song wrote:
>> +#include <linux/module.h>
>> +#include <linux/init.h>
>> +#include <linux/kernel.h>
>> +#include <linux/types.h>
>
> I think you don't need "types.h" as the code no longer uses "uint*_t".

linux/types.h declares all types, like u* which this driver still uses

> Well, I'm still not a friend of the following inline functions,
> especially the *one-liners* which are called just *once*. With the usage
> of structs they seem even more useless.

seems like it would make more sense to not even use the read/write
functions either.  just declare the regs as volatile and assign/read
the struct directly.
-mike
