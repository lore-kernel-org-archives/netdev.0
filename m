From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 0/8] split out emac cpdma and mdio for reuse
Date: Thu, 26 Aug 2010 11:39:05 -0700
Message-ID: <87r5hl2p86.fsf@deeprootsystems.com>
References: <1280842313-3743-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, srk@ti.com
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:33804 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924Ab0HZSjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 14:39:09 -0400
In-Reply-To: <1280842313-3743-1-git-send-email-cyril@ti.com> (Cyril
	Chemparathy's message of "Tue, 3 Aug 2010 09:31:45 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyril Chemparathy <cyril@ti.com> writes:

> Davinci's EMAC device has an in-built MDIO controller and a CPDMA engine.
> These hardware modules are not restricted to EMAC device alone.  For example,
> CPSW3G (3-port gigabit ethernet switch) hardware uses these very same modules
> internally.  This patch series separates out EMAC's MDIO and CPDMA
> functionality, allowing these individual pieces to be reused across TI
> hardware.  

Hi Cyril,

Another minor request for v2.  

The subject for the drivers/net/* patches should be something like
'net: davinci_emac: ..." instead of netdev.

Thanks,

Kevin
