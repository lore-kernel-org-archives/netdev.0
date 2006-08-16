From: "Giacomo A. Catenazzi" <cate@debian.org>
Subject: Re: bonding: cannot remove certain named devices
Date: Wed, 16 Aug 2006 08:35:08 +0200
Message-ID: <44E2BC9C.1000101@debian.org>
References: <6KfTz-OX-11@gated-at.bofh.it>	<6KfTA-OX-15@gated-at.bofh.it>	<E1GD8rX-0001cA-CV@be1.lrz> <20060815.171002.104028951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: 7eggert@gmx.de, 7eggert@elstempel.de, shemminger@osdl.org,
	mitch.a.williams@intel.com, notting@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion2.pixelized.ch ([195.190.190.13]:38309 "EHLO
	mail.pixelized.ch") by vger.kernel.org with ESMTP id S1750790AbWHPGfV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 02:35:21 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060815.171002.104028951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Bodo Eggert <7eggert@elstempel.de>
> Date: Wed, 16 Aug 2006 02:02:03 +0200
> 
>> Stephen Hemminger <shemminger@osdl.org> wrote:
>>
>>> IMHO idiots who put space's in filenames should be ignored. As long as the
>>> bonding code doesn't throw a fatal error, it has every right to return
>>> "No such device" to the fool.
>> Maybe you should limit device names to eight uppercase characters and up to
>> three characters extension, too. NOT! There is no reason to artificially
>> impose limitations on device names, so don't do that.
> 
> Are you willing to work to add the special case code necessary to
> handle whitespace characters in the device name over all of the kernel
> code and also all of the userland tools too?

But if you don't handle spaces in userspace, you handle *, ?, [, ], $,
", ', \  in userspace? Should kernel disable also these (insane device
chars) chars?

ciao
	cate
> 
> No?  Great, I'm glad that's settled.

