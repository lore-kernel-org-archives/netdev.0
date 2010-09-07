From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/caif: Use pr_fmt
Date: Mon, 06 Sep 2010 18:40:30 -0700 (PDT)
Message-ID: <20100906.184030.91320907.davem@davemloft.net>
References: <1283758271.23280.73.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756012Ab0IGBkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:40:12 -0400
In-Reply-To: <1283758271.23280.73.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 06 Sep 2010 00:31:11 -0700

> This patch standardizes caif message logging prefixes.
> 
> Add #define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
> Add missing "\n"s to some logging messages 
> Convert pr_warning to pr_warn
> 
> This changes the logging message prefix from CAIF: to caif:
> for all uses but caif_socket.c and chnl_net.c.  Those now use
> their filename without extension.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
