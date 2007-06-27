From: David Miller <davem@davemloft.net>
Subject: Re: resend [PATCH 3/5 2.6.21] L2TP: PPP over L2TP driver core
Date: Wed, 27 Jun 2007 00:20:18 -0700 (PDT)
Message-ID: <20070627.002018.93387101.davem@davemloft.net>
References: <200705261747.l4QHlOkl001722@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752711AbXF0HT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 03:19:59 -0400
In-Reply-To: <200705261747.l4QHlOkl001722@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Sat, 26 May 2007 18:47:24 +0100

> This driver handles only L2TP data frames; control frames are handled
> by a userspace application. It implements L2TP using the PPPoX socket
> family. There is a PPPoX socket for each L2TP session in an L2TP tunnel.
> PPP data within each session is passed through the kernel's
> PPP subsystem via this driver. Kernel parameters of each socket can be
> read or modified using ioctl() or [gs]etsockopt() calls.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

I have no major objections to this patch and would apply
it except for the UDP decapsulation issues.

My suggestion seemingly would work fine here, you could
set the UDP socket callback function pointer when you
set the encap_type.

Please give it a try.

Thanks!
