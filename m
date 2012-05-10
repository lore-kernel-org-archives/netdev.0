From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] netlink: connector: implement cn_netlink_reply
Date: Thu, 10 May 2012 04:45:53 +0400
Message-ID: <20120510004553.GB8362@ioremap.net>
References: <1336574243-12063-1-git-send-email-alban.crequy@collabora.co.uk>
 <1336609248.2499.20.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	netdev@vger.kernel.org,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:60378 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761490Ab2EJAzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 20:55:10 -0400
Content-Disposition: inline
In-Reply-To: <1336609248.2499.20.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 10, 2012 at 01:20:48AM +0100, Ben Hutchings (bhutchings@solarflare.com) wrote:
> On Wed, 2012-05-09 at 15:37 +0100, Alban Crequy wrote:
> > In a connector callback, it was not possible to reply to a message only to a
> > sender. This patch implements cn_netlink_reply(). It uses the connector socket
> > to send an unicast netlink message back to the sender.
> [...]
> 
> We try to avoid adding functions with no users.  You'll need to submit
> the code that's intended to use this as well.

I have no objection against this patch, but as correctly stated it is
useless without users. Alban, what is the code you want this
functionality to be used in? Do you plan to submit it? Can you submit
this change in the patch with your code?

-- 
	Evgeniy Polyakov
