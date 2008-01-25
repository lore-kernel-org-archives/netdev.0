From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH for-2.6.25] [POWERPC] Rename commproc to cpm1 and
 cpm2_common.c to cpm2.c
Date: Fri, 25 Jan 2008 09:56:12 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0801250955580.16736@blarg.am.freescale.net>
References: <4799F2CE.309@scram.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vitaly Bordug <vitb@kernel.crashing.org>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Scott Wood <scottwood@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kernel, Linux" <linux-kernel@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Jochen Friedrich <jochen@scram.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34416 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754081AbYAYQBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 11:01:10 -0500
In-Reply-To: <4799F2CE.309@scram.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jan 2008, Jochen Friedrich wrote:

> Rename commproc.[ch] to cpm1.[ch] to be more consistent with cpm2. Also
> rename cpm2_common.c to cpm2.c as suggested by Scott Wood. Adjust the
> includes accordingly.
>
> Signed-off-by: Jochen Friedrich <jochen@scram.de>
> ---
>  arch/powerpc/platforms/8xx/ep88xc.c           |    1 +
>  arch/powerpc/platforms/8xx/mpc86xads_setup.c  |    2 +-
>  arch/powerpc/platforms/8xx/mpc885ads_setup.c  |    2 +-
>  arch/powerpc/sysdev/Makefile                  |    4 ++--
>  arch/powerpc/sysdev/{commproc.c => cpm1.c}    |    4 ++--
>  arch/powerpc/sysdev/{cpm2_common.c => cpm2.c} |    3 +--
>  arch/powerpc/sysdev/micropatch.c              |    2 +-
>  arch/ppc/8260_io/enet.c                       |    2 +-
>  arch/ppc/8xx_io/commproc.c                    |    2 +-
>  arch/ppc/8xx_io/enet.c                        |    6 +++---
>  arch/ppc/8xx_io/fec.c                         |    2 +-
>  arch/ppc/8xx_io/micropatch.c                  |    2 +-
>  arch/ppc/boot/simple/iic.c                    |    2 +-
>  arch/ppc/boot/simple/m8xx_tty.c               |    2 +-
>  arch/ppc/kernel/ppc_ksyms.c                   |    2 +-
>  arch/ppc/platforms/mpc866ads_setup.c          |    2 +-
>  arch/ppc/platforms/mpc885ads_setup.c          |    2 +-
>  arch/ppc/syslib/mpc8xx_devices.c              |    2 +-
>  arch/ppc/xmon/start_8xx.c                     |    2 +-
>  drivers/net/fec_8xx/fec_8xx-netta.c           |    2 +-
>  drivers/net/fec_8xx/fec_main.c                |    2 +-
>  drivers/net/fec_8xx/fec_mii.c                 |    2 +-
>  drivers/net/fs_enet/fs_enet.h                 |    2 +-
>  drivers/net/fs_enet/mac-fec.c                 |    2 +-
>  drivers/net/fs_enet/mac-scc.c                 |    2 +-
>  drivers/serial/cpm_uart/cpm_uart_cpm1.h       |    2 +-
>  include/asm-powerpc/{commproc.h => cpm1.h}    |    8 ++++----
>  include/asm-ppc/{commproc.h => cpm1.h}        |    8 ++++----
>  28 files changed, 38 insertions(+), 38 deletions(-)
>  rename arch/powerpc/sysdev/{commproc.c => cpm1.c} (99%)
>  rename arch/powerpc/sysdev/{cpm2_common.c => cpm2.c} (99%)
>  rename include/asm-powerpc/{commproc.h => cpm1.h} (99%)
>  rename include/asm-ppc/{commproc.h => cpm1.h} (99%)
>

applied.

- k
