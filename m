From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] Eliminate user-selectable CONFIG_MV643XX_ETH_[012]
Date: Tue, 20 Feb 2007 12:22:38 +0000
Message-ID: <20070220122238.GA27855@linux-mips.org>
References: <20070220121520.GA17927@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:45529 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932909AbXBTMWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 07:22:48 -0500
Received: from localhost.localdomain ([127.0.0.1]:43442 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20038954AbXBTMWq (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 1 other); Tue, 20 Feb 2007 12:22:46 +0000
Content-Disposition: inline
In-Reply-To: <20070220121520.GA17927@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 05:15:20AM -0700, Dale Farnsworth wrote:

> From: Dale Farnsworth <dale@farnsworth.org>
> 
> Remove the use of CONFIG_MV643XX_ETH_[012] variables on most
> platforms.  Instead, platform-specific code enables the ports
> supported by the hardware.  After this patch, these config
> variables are only used in arch/ppc, so also move them from
> drivers/net/Kconfig to arch/ppc/Kconfig.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
