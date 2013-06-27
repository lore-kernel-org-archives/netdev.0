From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 6/7] drivers: ssb: Kconfig: Amend SSB_EMBEDDED
 dependencies
Date: Thu, 27 Jun 2013 13:30:10 +0200
Message-ID: <20130627113010.GU7171@linux-mips.org>
References: <1371477641-7989-1-git-send-email-markos.chandras@imgtec.com>
 <1371477641-7989-7-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, sibyte-users@bitmover.com,
	netdev@vger.kernel.org, Michael Buesch <m@bues.ch>
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:57262 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab3F0LaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 07:30:23 -0400
Received: from localhost.localdomain ([127.0.0.1]:52211 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6818020Ab3F0LaVvblvy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jun 2013 13:30:21 +0200
Content-Disposition: inline
In-Reply-To: <1371477641-7989-7-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 17, 2013 at 03:00:40PM +0100, Markos Chandras wrote:

> SSB_EMBEDDED needs functions from driver_pcicore which are only
> available if SSD_DRIVER_HOSTMODE is selected so make it
> depend on that symbol.
> 
> Fixes the following linking problem:
> 
> drivers/ssb/embedded.c:202:
> undefined reference to `ssb_pcicore_plat_dev_init'
> drivers/built-in.o: In function `ssb_pcibios_map_irq':
> drivers/ssb/embedded.c:247:
> undefined reference to `ssb_pcicore_pcibios_map_irq'
> 
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
> Acked-by: Steven J. Hill <Steven.Hill@imgtec.com>
> Cc: sibyte-users@bitmover.com
> Cc: netdev@vger.kernel.org
> Cc: Michael Buesch <m@bues.ch>

No comments received but Florian acked it over IRC so applied.

And btw, why is sibyte-users on cc - we don't want to disrupt the silence
of that list too badly ;-)

  Ralf
