From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: mark BIC as experimental
Date: Fri, 31 Oct 2008 09:41:13 -0700
Message-ID: <20081031094113.2bab9140@extreme>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
	<20081030083641.55e936b0@extreme>
	<20081031.005033.172610018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56258 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbYJaQlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 12:41:18 -0400
In-Reply-To: <20081031.005033.172610018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Oct 2008 00:50:33 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 30 Oct 2008 08:36:41 -0700
> 
> > Change the configuration defaults to mark BIC as experimental.
> > BIC is too aggressive and was replaced by CUBIC. Debian was picking
> > BIC in their default config (should be fixed by now), but the configuration
> > documentation did not make it explicit that this was a bad idea.
> > 
> > Also update the URLs in the configuration documentation to current
> > locations.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> I understand your intention, but I'm not so sure we should do this.
> 
> It's more than a double standard to make this change, yet still
> allow things like HTCP to still be a default.
> 
> And you can't even make this selection without asking for
> TCP_CONG_ADVANCED.   Well... duh!

Some architectures were setting TCP_CONG_ADVANCED and choosing BIC


arch/arm/configs/at91rm9200dk_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/at91rm9200ek_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/ateb9200_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/collie_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/kafa_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/kb9202_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/ks8695_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/lpd7a404_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/netx_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/pnx4008_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/realview_defconfig:CONFIG_TCP_CONG_BIC=y
arch/arm/configs/versatile_defconfig:CONFIG_TCP_CONG_BIC=y
arch/ia64/configs/bigsur_defconfig:CONFIG_TCP_CONG_BIC=y
arch/ia64/configs/gensparse_defconfig:CONFIG_TCP_CONG_BIC=y
arch/ia64/configs/sim_defconfig:CONFIG_TCP_CONG_BIC=y
arch/mips/configs/bcm47xx_defconfig:CONFIG_TCP_CONG_BIC=y
arch/mips/configs/rb532_defconfig:CONFIG_TCP_CONG_BIC=m
arch/mips/configs/tb0287_defconfig:CONFIG_TCP_CONG_BIC=y
arch/powerpc/configs/ppc6xx_defconfig:CONFIG_TCP_CONG_BIC=m
