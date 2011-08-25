From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/10][pull request] Complete drivers/net/ move
Date: Wed, 24 Aug 2011 22:04:36 -0700 (PDT)
Message-ID: <20110824.220436.2170925789602864954.davem@davemloft.net>
References: <1314247835-24586-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab1HYFEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 01:04:41 -0400
In-Reply-To: <1314247835-24586-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Aug 2011 21:50:25 -0700

> The following are changes since commit 0856a304091b33a8e8f9f9c98e776f425af2b625:
>   Scm: Remove unnecessary pid & credential references in Unix socket's send and receive path
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

Still fails.

Jeff, I'm not pulling any more, you're simply not testing this
properly.  You need to sit on this for a few days and start properly
sanity checking what you're sending me.  I should not get a broken
build when I just type make on an "allmodconfig" tree right after
I pull from you.

Repeat, that should never happen, ever.

It's not rocket science what I do to sanity test this.

Take a vanilla net-next tree, "make allmodconfig" and build it.

Pull your tree, "make oldconfig" and try to build it again, it fails.

Why aren't you testing that?  Because that's the first thing the rest
of the world, especially everyone validating the -next tree, is going
to do.

ERROR: "pppox_ioctl" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "unregister_pppox_proto" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "register_pppox_proto" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_input" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "pppox_unbind_sock" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_register_net_channel" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_dev_name" [net/l2tp/l2tp_ppp.ko] undefined!
ERROR: "ppp_unit_number" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_unregister_channel" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_output_wakeup" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_input_error" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_input" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_register_channel" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_channel_index" [net/irda/irnet/irnet.ko] undefined!
ERROR: "ppp_input_error" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_input" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_unregister_channel" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_output_wakeup" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_unit_number" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_channel_index" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_register_channel" [net/atm/pppoatm.ko] undefined!
ERROR: "ppp_unit_number" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_unregister_channel" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_output_wakeup" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_input" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_register_channel" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "ppp_channel_index" [drivers/tty/ipwireless/ipwireless.ko] undefined!
ERROR: "slhc_init" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_remember" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_uncompress" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_free" [drivers/isdn/i4l/isdn.ko] undefined!
ERROR: "slhc_compress" [drivers/isdn/i4l/isdn.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2
make: *** Waiting for unfinished jobs....
Succeed: decoded and checked 1378429 instructions
Setup is 16588 bytes (padded to 16896 bytes).
System is 4577 kB
CRC b144d738
Kernel: arch/x86/boot/bzImage is ready  (#51)
