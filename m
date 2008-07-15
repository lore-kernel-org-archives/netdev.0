From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bluetooth/hci_bcsp: fix bitrev Kconfig
Date: Tue, 15 Jul 2008 00:51:54 -0700 (PDT)
Message-ID: <20080715.005154.255934765.davem@davemloft.net>
References: <20080618140612.5384f97c.randy.dunlap@oracle.com>
	<1213828239.19292.4.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, maxk@qualcomm.com
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60811
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754258AbYGOHvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 03:51:54 -0400
In-Reply-To: <1213828239.19292.4.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 19 Jun 2008 00:30:39 +0200

> > Fix bluetooth hci_bcsp Kconfig to avoid build errors:
> > 
> > drivers/built-in.o: In function `bcsp_prepare_pkt':
> > hci_bcsp.c:(.text+0x7e9ac): undefined reference to `bitrev16'
> > drivers/built-in.o: In function `bcsp_recv':
> > hci_bcsp.c:(.text+0x7f276): undefined reference to `bitrev16'
> > hci_bcsp.c:(.text+0x7f293): undefined reference to `bitrev16'
> > make[1]: *** [.tmp_vmlinux1] Error 1
> > 
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Ackey-by: Marcel Holtmann <marcel@holtmann.org>

Applied, thanks everyone.
