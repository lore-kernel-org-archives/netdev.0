From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 16:25:14 -0500 (EST)
Message-ID: <20141114.162514.65504859624082054.davem@davemloft.net>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux.nics@intel.com
To: martin.petersen@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161796AbaKNVZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 16:25:19 -0500
In-Reply-To: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Martin K. Petersen" <martin.petersen@oracle.com>
Date: Fri, 14 Nov 2014 14:16:50 -0500

> +#ifdef CONFIG_OF
> +#include <asm/idprom.h>
> +#include <asm/prom.h>
> +#endif

CONFIG_OF doesn't imply the presence of idprom.

idprom is completely sparc/m68k specific, whereas OF exists on many
platforms other than sparc/m68k.
