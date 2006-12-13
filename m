From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6 patch] drivers/net/loopback.c: convert to module_init()
Date: Wed, 13 Dec 2006 15:01:43 -0800
Message-ID: <20061213150143.2672e0b1@dxpl.pdx.osdl.net>
References: <20061212162435.GW28443@stusta.de>
	<20061212.171756.85408589.davem@davemloft.net>
	<20061213201213.GK4587@ftp.linux.org.uk>
	<20061213204933.GW8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ftp.linux.org.uk>,
	David Miller <davem@davemloft.net>, bunk@stusta.de,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:54698 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbWLMXFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 18:05:12 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061213204933.GW8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Dec 2006 21:49:33 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * Al Viro <viro@ftp.linux.org.uk> 2006-12-13 20:12
> > On Tue, Dec 12, 2006 at 05:17:56PM -0800, David Miller wrote:
> > > I'm not sure whether that is important any longer.  It probably isn't,
> > > but we should verify it before applying such a patch.
> > 
> > There might be practical considerations along the lines of "we want
> > lookups for loopback to be fast"...
> 
> What is this discussion actually about? Since we started registering
> devices directly hooked into the init process before device_initcall()
> the order is random. Even the bonding device is registered before the
> loopback.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Loopback should be there before protocols are started. It makes sense
to have a standard startup order.
