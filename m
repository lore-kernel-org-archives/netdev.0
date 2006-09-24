From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: remove unused include file
Date: Sun, 24 Sep 2006 21:04:13 +0100
Message-ID: <1159128253.24527.951.camel@pmac.infradead.org>
References: <200609240005.k8O05uNk015180@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:14556 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751341AbWIXUEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 16:04:25 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200609240005.k8O05uNk015180@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-24 at 00:05 +0000, Linux Kernel Mailing List wrote:
> [NETFILTER]: remove unused include file
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
>  include/linux/netfilter_logging.h |   33 ---------------------------------
>  1 file changed, 33 deletions(-) 

You neglected to also remove the file from include/linux/Kbuild.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -267,7 +267,6 @@ unifdef-y += netfilter_decnet.h
 unifdef-y += netfilter.h
 unifdef-y += netfilter_ipv4.h
 unifdef-y += netfilter_ipv6.h
-unifdef-y += netfilter_logging.h
 unifdef-y += net.h
 unifdef-y += netlink.h
 unifdef-y += nfs3.h

-- 
dwmw2

