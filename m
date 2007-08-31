From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] PS3: fix the bug that 'ifconfig down' would hang
Date: Fri, 31 Aug 2007 06:53:50 -0400
Message-ID: <46D7F33E.3000704@garzik.org>
References: <20070828125924.C2B1.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Lothian <mike@fireburn.co.uk>,
	Stefan Assmann <sassmann@suse.de>, geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>,
	cbe-oss-dev@ozlabs.org, ppc@suse.de,
	Linas Vepstas <linas@austin.ibm.com>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59509 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932853AbXHaKxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 06:53:55 -0400
In-Reply-To: <20070828125924.C2B1.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masakazu Mokuno wrote:
> Fix the bug that 'ifconfig eth0 down' would hang up, reported by Stefan
> Assmann <sassmann@suse.de>.
> As we removed netif_poll_enable() from dev->open(), we should not use 
> netif_poll_disable() in dev->stop(). 
> 
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> CC: Geoff Levand <geoffrey.levand@am.sony.com>
> ---
>  drivers/net/ps3_gelic_net.c |    1 -
>  1 file changed, 1 deletion(-)

applied


