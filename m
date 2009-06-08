From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: SMC91x: forcing speed
Date: Mon, 8 Jun 2009 14:02:05 +0200
Message-ID: <ba4215e10906080502u3966a301vb2d7162f48694a4b@mail.gmail.com>
References: <ba4215e10906040608m36538458u60a7971834f26d2@mail.gmail.com>
	 <4A27E20C.4020603@endian.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Richard_R=F6jfors?= <richard.rojfors@endian.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:65158 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822AbZFHMCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 08:02:04 -0400
Received: by ewy6 with SMTP id 6so4087155ewy.37
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2009 05:02:05 -0700 (PDT)
In-Reply-To: <4A27E20C.4020603@endian.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Martin Fuzzey wrote:
>> Hi,
>>
>> Is there a better way of doing this that would be acceptable for mainline?
>
> Look at include/linux/ethtool.h.
>

Thank you for your reply.

The smc91x driver already has ethtool support.
However, as I stated in my original post, I don't want to use ethtool
from userspace since I need to be able to use a NFS rootfs.

So is there already a programmatic way of using the ethool interface
from the board specific setup code?
Or are you proposing adding a struct ethtool_cmd to smc91x_platdata ?

Another way I can think of is just to add a generic init() callback to
the platform data so that my board specific code can get at the
struct net_device * and then use the ethtool interface via dev->ethtool_ops.

Regards,

Martin
