From: Michael Williamson <michael.williamson@criticallink.com>
Subject: Re: [PATCH v2 05/10] davinci: cleanup unused davinci mdio arch code
Date: Thu, 02 Sep 2010 22:19:40 -0400
Message-ID: <4C805B3C.9040804@criticallink.com>
References: <1283465008-18606-1-git-send-email-cyril@ti.com> <1283465008-18606-6-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, srk@ti.com,
	davinci-linux-open-source@linux.davincidsp.com,
	omar.ramirez@ti.com, linux-omap@vger.kernel.org
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61850 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348Ab0ICCTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 22:19:44 -0400
In-Reply-To: <1283465008-18606-6-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2010 06:03 PM, Cyril Chemparathy wrote:
> This patch removes davinci architecture code that has now been rendered
> useless by the previous patches in the MDIO separation series.
> 
> Signed-off-by: Cyril Chemparathy <cyril@ti.com>
> ---
>  arch/arm/mach-davinci/board-da830-evm.c     |    5 -----
>  arch/arm/mach-davinci/board-da850-evm.c     |    6 ------
>  arch/arm/mach-davinci/board-dm365-evm.c     |    7 -------
>  arch/arm/mach-davinci/board-dm644x-evm.c    |    7 -------
>  arch/arm/mach-davinci/board-dm646x-evm.c    |    8 --------
>  arch/arm/mach-davinci/board-neuros-osd2.c   |    7 -------
>  arch/arm/mach-davinci/board-sffsdr.c        |    7 -------

[snip]

There is a new/pending board file in the davinci-linux tree that
will also need to be updated in similar fashion as the 
board-da850-evm.

arch/arm/mach-davinci/board-mityomapl138.c

-Mike
