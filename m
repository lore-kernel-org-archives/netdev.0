From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 7/9] net drivers: fix platform driver hotplug/coldplug
Date: Fri, 25 Apr 2008 02:03:53 -0400
Message-ID: <48117449.4070604@garzik.org>
References: <200804182050.m3IKoi47014840@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kay.sievers@vrfy.org, andrew@sanpeople.com,
	ben-linux@fluff.org, bryan.wu@analog.com, dale@farnsworth.org,
	dbrownell@users.sourceforge.net, ralf@linux-mips.org,
	scottwood@freescale.com, vitb@kernel.crashing.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58559 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755044AbYDYGD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:03:59 -0400
In-Reply-To: <200804182050.m3IKoi47014840@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Kay Sievers <kay.sievers@vrfy.org>
> 
> Since 43cc71eed1250755986da4c0f9898f9a635cb3bf, the platform modalias is
> prefixed with "platform:".  Add MODULE_ALIAS() to the hotpluggable network
> platform drivers, to re-enable auto loading.
> 
> NOTE: didn't change drivers/net/fs_enet/fs_enet-main.c "old binding" support. 
> That looks problematic in the first place (it even uses the ancient "struct
> device_driver" binding scheme for platform_bus!) and I suspect it will vanish
> soonish when arch/powerpc rules the world.  Also, drivers/net/ne.c would have
> needed more thought to sort out.
> 
> [akpm@linux-foundation.org: fix sgiseeq.c]
> [dbrownell@users.sourceforge.net: more drivers, registration fixes]
> Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Scott Wood <scottwood@freescale.com>
> Cc: Vitaly Bordug <vitb@kernel.crashing.org>
> Cc: Dale Farnsworth <dale@farnsworth.org>
> Cc: Ben Dooks <ben-linux@fluff.org>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Andrew Victor <andrew@sanpeople.com>
> Cc: Bryan Wu <bryan.wu@analog.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied


