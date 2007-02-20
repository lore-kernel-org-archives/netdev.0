From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Eliminate user-selectable CONFIG_MV643XX_ETH_[012]
Date: Tue, 20 Feb 2007 11:27:30 -0500
Message-ID: <45DB2172.1070003@garzik.org>
References: <20070220121520.GA17927@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Mackerras <paulus@samba.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030231AbXBTQ1j@vger.kernel.org>
In-Reply-To: <20070220121520.GA17927@xyzzy.farnsworth.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> From: Dale Farnsworth <dale@farnsworth.org>
> 
> Remove the use of CONFIG_MV643XX_ETH_[012] variables on most
> platforms.  Instead, platform-specific code enables the ports
> supported by the hardware.  After this patch, these config
> variables are only used in arch/ppc, so also move them from
> drivers/net/Kconfig to arch/ppc/Kconfig.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> 
> ---
> It was a mis-feature that the supported ports were ever user-selectable.
> Which ports the hardware supports should be specified by platform-specific
> code, not by the user.
> 
>  arch/mips/momentum/jaguar_atx/platform.c |   21 ---------------------
>  arch/mips/momentum/ocelot_3/platform.c   |   21 ---------------------
>  arch/mips/momentum/ocelot_c/platform.c   |   14 --------------
>  arch/ppc/Kconfig                         |   15 +++++++++++++++
>  drivers/net/Kconfig                      |   21 ---------------------
>  5 files changed, 15 insertions(+), 77 deletions(-)

ACK.

I'll let Paul, Ralf or Andrew push this one upstream.
