From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v6 0/9] net: Unified offload configuration
Date: Fri, 18 Feb 2011 14:29:31 +0000
Message-ID: <1298039371.2211.9.camel@localhost>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
	 <20110217.145611.229745070.davem@davemloft.net>
	 <20110218142238.GA18099@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32265 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758229Ab1BRO3f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 09:29:35 -0500
In-Reply-To: <20110218142238.GA18099@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-18 at 15:22 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> On Thu, Feb 17, 2011 at 02:56:11PM -0800, David Miller wrote:
[...]
> > Please get rid of that annoying message spit out by netif_features_=
change(),
> > it's just spam.  If we want notifications for stuff like this, use =
a
> > non-unicast netlink message so those who want to hear it can do so.
>=20
> You mean netdev_update_features() "Features changed" message? Is it o=
k
> to just demote it to DEBUG level or you want to remove it altogether?
> What about netdev_fix_features() messages?

I think you need to emit these messages at 'error' severity when fixing
up features for a newly-added device, but at 'debug' later on.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

