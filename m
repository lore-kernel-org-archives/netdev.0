From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] au1000_eth.c: use ether_crc() from <linux/crc32.h>
Date: Tue, 2 May 2006 21:34:27 +0100
Message-ID: <20060502203427.GC3474@linux-mips.org>
References: <E1FaYil-0007A8-HB@fencepost.gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:16586 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1751322AbWEBUej
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 16:34:39 -0400
Received: from localhost.localdomain ([127.0.0.1]:7878 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133952AbWEBUei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 21:34:38 +0100
To: Herbert Valerio Riedel <hvr@gnu.org>
Content-Disposition: inline
In-Reply-To: <E1FaYil-0007A8-HB@fencepost.gnu.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2006 at 01:46:42PM +0000, Herbert Valerio Riedel wrote:

> since the au1000 driver already selects the CRC32 routines, simply replace
> the internal ether_crc() implementation with the semantically equivalent
> one from <linux/crc32.h>
> 
> Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>

Looks good to me.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
