From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netlink: connector: implement cn_netlink_reply
Date: Thu, 10 May 2012 01:20:48 +0100
Message-ID: <1336609248.2499.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336574243-12063-1-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, <netdev@vger.kernel.org>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64391 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761396Ab2EJAUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 20:20:53 -0400
In-Reply-To: <1336574243-12063-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-09 at 15:37 +0100, Alban Crequy wrote:
> In a connector callback, it was not possible to reply to a message only to a
> sender. This patch implements cn_netlink_reply(). It uses the connector socket
> to send an unicast netlink message back to the sender.
[...]

We try to avoid adding functions with no users.  You'll need to submit
the code that's intended to use this as well.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
