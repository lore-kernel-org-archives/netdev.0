From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPVS] Added include for ip_vs.h for
 ctl_path (build was broken)
Date: Wed, 09 Jan 2008 03:57:00 -0800 (PST)
Message-ID: <20080109.035700.103587122.davem@davemloft.net>
References: <eb3ff54b0801090333r4c1770dakd65f61e356aa0304@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52434
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752560AbYAIL5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 06:57:00 -0500
In-Reply-To: <eb3ff54b0801090333r4c1770dakd65f61e356aa0304@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Wed, 9 Jan 2008 13:33:49 +0200

> Hi,
>    The build was broken with this error:
> 	
>   In file included from net/ipv4/ipvs/ip_vs_rr.c:27:
>   include/net/ip_vs.h:857: error: array type has incomplete element type
>   make[3]: *** [net/ipv4/ipvs/ip_vs_rr.o] Error 1
> 
> 	This was due to missing include to the header file for ctl_path.
> 	
> 	This patch added #include <linux/sysctl.h> to ip_vs_.h to avoid it
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
