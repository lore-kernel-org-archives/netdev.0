From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/9] com20020 build fix
Date: Fri, 10 Nov 2006 11:09:44 -0500
Message-ID: <4554A448.2070208@garzik.org>
References: <200611090351.kA93p3Vw003681@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	randy.dunlap@oracle.com, toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12932 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1946306AbWKJQJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:09:49 -0500
To: akpm@osdl.org
In-Reply-To: <200611090351.kA93p3Vw003681@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> com20020.c needs to export functions if either of the ISA or PCI modules
> are built as loadable modules.  Or they could always be exported.
> 
> WARNING: "com20020_found" [drivers/net/arcnet/com20020-pci.ko] undefined!
> WARNING: "com20020_check" [drivers/net/arcnet/com20020-pci.ko] undefined!
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Toralf Forster <toralf.foerster@gmx.de>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied; please CC me on this drivers/net stuff


