From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: pull request: wireless-next-2.6 2009-06-04
Date: Sun, 07 Jun 2009 16:18:41 +0200
Message-ID: <4A2BCC41.1060508@hartkopp.net>
References: <20090604152011.GC2839@tuxdriver.com> <20090607.033751.191866033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:31439 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbZFGOSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 10:18:43 -0400
In-Reply-To: <20090607.033751.191866033.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Thu, 4 Jun 2009 11:20:11 -0400
> 
>> Hopefully this is (almost?) the last wireless pull request for
>> non-bugfix patches intended for 2.6.31...
>>

(..)

>>
>> Please let me know if there are problems!
> 
> Pulled into net-next-2.6 and I'll push it back out to kernel.org
> after some build testing.

Hi John,

after pulling the latest net-next-2.6 i got this warning which is probably
caused by CONFIG_RFKILL=m in my config:

hartko@vwagwolkf320:~/net-next-2.6$ make oldconfig
scripts/kconfig/conf -o arch/x86/Kconfig
.config:614:warning: symbol value 'm' invalid for RFKILL_INPUT
*
* Restart config...
*
*
* RF switch subsystem support
*
RF switch subsystem support (RFKILL) [M/n/y/?] m
  RF switch input support (RFKILL_INPUT) [Y/n] (NEW)
#
# configuration written to .config
#
hartko@vwagwolkf320:~/net-next-2.6$ make -j2
scripts/kconfig/conf -s arch/x86/Kconfig
include/config/auto.conf:578:warning: symbol value 'm' invalid for RFKILL_INPUT
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  UPD     include/linux/utsrelease.h
...

Regards,
Oliver

