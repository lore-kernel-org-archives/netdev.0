From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Fri, 29 Oct 2010 05:21:35 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1010290516110.25426@eddie.linux-mips.org>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com> <1288315159-1350-6-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:53871 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab0J2EVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 00:21:36 -0400
Received: from localhost.localdomain ([127.0.0.1]:52813 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1490983Ab0J2EVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 06:21:35 +0200
In-Reply-To: <1288315159-1350-6-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Oct 2010, Paul Gortmaker wrote:

> DEC as a name brand has been gone for over 10 years, and these
> drivers represent technology from the 1990's like the venerable
> ISA bus.  Hence relocate them to the legacy dir.

 NAK for the TURBOchannel bits (defxx.[ch] and declance.c) unless you give 
a plausible justification.  You won't get these drivers offered unless you 
have the bus in your system anyway, and if you do than you don't want to 
have them hidden somewhere in the corner.  If you see anything wrong with 
these drivers, then please do let me know.

 Also defxx.c is PCI too (apart from being EISA and TC).

> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  drivers/net/Kconfig                 |   63 -----------------------------------
>  drivers/net/Makefile                |    4 --
>  drivers/net/legacy/Kconfig          |   63 +++++++++++++++++++++++++++++++++++
>  drivers/net/legacy/Makefile         |    5 +++
>  drivers/net/{ => legacy}/declance.c |    0
>  drivers/net/{ => legacy}/defxx.c    |    0
>  drivers/net/{ => legacy}/defxx.h    |    0
>  drivers/net/{ => legacy}/depca.c    |    0
>  drivers/net/{ => legacy}/depca.h    |    0
>  drivers/net/{ => legacy}/ewrk3.c    |    0
>  drivers/net/{ => legacy}/ewrk3.h    |    0

  Maciej
