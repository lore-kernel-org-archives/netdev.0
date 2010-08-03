From: Igor Grinberg <grinberg@compulab.co.il>
Subject: Re: [PATCH 2/8] davinci: add mdio platform devices
Date: Tue, 03 Aug 2010 17:06:50 +0300
Message-ID: <4C58227A.4080502@compulab.co.il>
References: <1280842313-3743-1-git-send-email-cyril@ti.com> <1280842313-3743-3-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, nsekhar@ti.com, srk@ti.com
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from compulab.co.il ([67.18.134.219]:33636 "EHLO compulab.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756281Ab0HCOHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 10:07:00 -0400
In-Reply-To: <1280842313-3743-3-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/10 16:31, Cyril Chemparathy wrote:
> This patch adds mdio platform devices on SoCs that have the necessary
> hardware.  Clock lookup entries (aliases) have also been added, so that the
> MDIO and EMAC drivers can independently enable/disable a shared underlying
> clock.  Further, the EMAC MMR region has been split down into separate MDIO
> and EMAC regions.
>
> Signed-off-by: Cyril Chemparathy <cyril@ti.com>
> ---
>  arch/arm/mach-davinci/devices-da8xx.c       |   29 +++++++++++++++++++++++++-
>  arch/arm/mach-davinci/dm365.c               |   22 +++++++++++++++++++-
>  arch/arm/mach-davinci/dm644x.c              |   22 +++++++++++++++++++-
>  arch/arm/mach-davinci/dm646x.c              |   22 +++++++++++++++++++-
>  arch/arm/mach-davinci/include/mach/dm365.h  |    1 +
>  arch/arm/mach-davinci/include/mach/dm644x.h |    1 +
>  arch/arm/mach-davinci/include/mach/dm646x.h |    1 +
>  7 files changed, 93 insertions(+), 5 deletions(-)
>   

Shouldn't arch/arm/mach-omap2/board-am3517evm.c be on your list?
I think it should, or else it will be broken by:
[PATCH 5/8] netdev: cleanup unused davinci mdio emac code

-- 
Regards,
Igor.

