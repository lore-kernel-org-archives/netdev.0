From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] ucc_geth: use rx-clock-name and tx-clock-name device tree properties
Date: Fri, 14 Dec 2007 01:19:05 -0600
Message-ID: <6867E746-3CD5-4A49-8941-429CAEB1CCDD@kernel.crashing.org>
References: <11967166791607-git-send-email-timur@freescale.com> <1196716680381-git-send-email-timur@freescale.com> <1196716685975-git-send-email-timur@freescale.com>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55283 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682AbXLNHT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 02:19:27 -0500
In-Reply-To: <1196716685975-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 3, 2007, at 3:17 PM, Timur Tabi wrote:

> Updates the ucc_geth device driver to check the new rx-clock-name and
> tx-clock-name properties first.  If present, it uses the new function
> qe_clock_source() to obtain the clock source.  Otherwise, it checks  
> the
> deprecated rx-clock and tx-clock properties.
>
> Update the device trees for 832x, 836x, and 8568 to contain the new  
> property
> names only.
>
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
>
> This patch applies to Kumar's for-2.6.25 branch.  ucc_geth will  
> compile but not
> run if my other patch, "qe: add function qe_clock_source" has not  
> also been
> applied.
>
> arch/powerpc/boot/dts/mpc832x_mds.dts |    8 ++--
> arch/powerpc/boot/dts/mpc832x_rdb.dts |    8 ++--
> arch/powerpc/boot/dts/mpc836x_mds.dts |    8 ++--
> arch/powerpc/boot/dts/mpc8568mds.dts  |    8 ++--
> drivers/net/ucc_geth.c                |   55 ++++++++++++++++++++++++ 
> ++++++--
> 5 files changed, 67 insertions(+), 20 deletions(-)

applied.

- k
