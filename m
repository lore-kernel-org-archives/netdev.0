From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER Kconfig help text]: bridge: add ebt_nflog watcher
Date: Mon, 30 Jun 2008 20:21:27 +0200
Message-ID: <48692427.7090703@trash.net>
References: <m3bq1i6b41.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080800020501000502020602"
Cc: Peter Warasin <peter@endian.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42820 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932402AbYF3SV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 14:21:29 -0400
In-Reply-To: <m3bq1i6b41.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080800020501000502020602
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Krzysztof Halasa wrote:
> is the following really correct?
> e7bfd0a1a6c8f82977253dab19be9d9979c1ec1b
> 
> +	tristate "ebt: nflog support"
> +	depends on BRIDGE_NF_EBTABLES
> +	help
> +	  This option enables the nflog watcher, which allows to LOG
> +	  messages through the netfilter logging API, which can use
> +	  either the old LOG target, the old ULOG target or nfnetlink_log
> +	  as backend.
> +
> +	  This option adds the ulog watcher, that you can use in any rule
>                                ^^^^^^^^^^^^
> 
> ulog watcher?

That appears to be a cut-and-paste error. I've queued this fix.


--------------080800020501000502020602
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit d921ce404ad26e2169e8f89e9a59722ecff35fcf
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 30 20:21:07 2008 +0200

    netfilter: ebt_nflog: fix Kconfig typo
    
    The help text should refer to nflog instead of ulog. Noticed by
    Krzysztof Halasa <khc@pm.waw.pl>.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index 540df41..9094797 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -230,7 +230,7 @@ config BRIDGE_EBT_NFLOG
 	  either the old LOG target, the old ULOG target or nfnetlink_log
 	  as backend.
 
-	  This option adds the ulog watcher, that you can use in any rule
+	  This option adds the nflog watcher, that you can use in any rule
 	  in any ebtables table.
 
 	  To compile it as a module, choose M here.  If unsure, say N.

--------------080800020501000502020602--
