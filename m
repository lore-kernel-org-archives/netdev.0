From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: SMC91x: forcing speed
Date: Mon, 08 Jun 2009 23:42:47 +0200
Message-ID: <4A2D85D7.6050509@gmail.com>
References: <ba4215e10906040608m36538458u60a7971834f26d2@mail.gmail.com>	<4A27E20C.4020603@endian.se>	<ba4215e10906080502u3966a301vb2d7162f48694a4b@mail.gmail.com> <20090608.142257.141336772.davem@davemloft.net>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: richard.rojfors@endian.se, nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:40351 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbZFHVms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:42:48 -0400
Received: by ewy6 with SMTP id 6so4552717ewy.37
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2009 14:42:49 -0700 (PDT)
In-Reply-To: <20090608.142257.141336772.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> The smc91x driver already has ethtool support.
>> However, as I stated in my original post, I don't want to use ethtool
>> from userspace since I need to be able to use a NFS rootfs.
>>     
>
> You can set the ethtool setting from an initramfs before the
> NFS mount of the root filesystem occurs.
>   
Yes I sure could.
But I don't currently need a initramfs for anything else - adding one
would complicate the build and boot process.
IMHO the place for board specific hacks is in the board specifc startup
code - am I wrong?

Regards,

Martin


