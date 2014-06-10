From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] net: xen-netback: include linux/vmalloc.h again
Date: Tue, 10 Jun 2014 09:44:54 +0100
Message-ID: <20140610084454.GB28084@zion.uk.xensource.com>
References: <5508988.K5Wec8A6hA@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Wei Liu <wei.liu2@citrix.com>,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Josh Boyer <jwboyer@fedoraproject.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:39691 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754721AbaFJIoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 04:44:55 -0400
Content-Disposition: inline
In-Reply-To: <5508988.K5Wec8A6hA@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2014 at 10:34:36AM +0200, Arnd Bergmann wrote:
> commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into
> queue struct") added a use of vzalloc/vfree to interface.c, but
> removed the #include <linux/vmalloc.h> statement at the same time,
> which causes this build error:
> 
> drivers/net/xen-netback/interface.c: In function 'xenvif_free':
> drivers/net/xen-netback/interface.c:754:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>   vfree(vif->queues);
>   ^
> cc1: some warnings being treated as errors
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Andrew J. Bennieston <andrew.bennieston@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

This didn't happen to me when I built it on x86 though. Just curious,
did you build it on othet platform, say, ARM?

Wei.
