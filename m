From: David Miller <davem@davemloft.net>
Subject: Re: SMC91x: forcing speed
Date: Mon, 08 Jun 2009 14:22:57 -0700 (PDT)
Message-ID: <20090608.142257.141336772.davem@davemloft.net>
References: <ba4215e10906040608m36538458u60a7971834f26d2@mail.gmail.com>
	<4A27E20C.4020603@endian.se>
	<ba4215e10906080502u3966a301vb2d7162f48694a4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.rojfors@endian.se, nico@cam.org, netdev@vger.kernel.org
To: mfuzzey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59525
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbZFHVWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:22:55 -0400
In-Reply-To: <ba4215e10906080502u3966a301vb2d7162f48694a4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Fuzzey <mfuzzey@gmail.com>
Date: Mon, 8 Jun 2009 14:02:05 +0200

> The smc91x driver already has ethtool support.
> However, as I stated in my original post, I don't want to use ethtool
> from userspace since I need to be able to use a NFS rootfs.

You can set the ethtool setting from an initramfs before the
NFS mount of the root filesystem occurs.
