From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH -next] bluetooth/hci_bcsp: fix bitrev Kconfig
Date: Thu, 19 Jun 2008 00:30:39 +0200
Message-ID: <1213828239.19292.4.camel@violet>
References: <20080618140612.5384f97c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, akpm <akpm@linux-foundation.org>,
	maxk@qualcomm.com, davem@davemloft.net
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53397 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbYFRWam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 18:30:42 -0400
In-Reply-To: <20080618140612.5384f97c.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Randy,

> Fix bluetooth hci_bcsp Kconfig to avoid build errors:
> 
> drivers/built-in.o: In function `bcsp_prepare_pkt':
> hci_bcsp.c:(.text+0x7e9ac): undefined reference to `bitrev16'
> drivers/built-in.o: In function `bcsp_recv':
> hci_bcsp.c:(.text+0x7f276): undefined reference to `bitrev16'
> hci_bcsp.c:(.text+0x7f293): undefined reference to `bitrev16'
> make[1]: *** [.tmp_vmlinux1] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Ackey-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


