From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH update] firewire: net: add carrier detection
Date: Sun, 12 Dec 2010 23:05:34 +0000
Message-ID: <1292195134.3136.296.camel@localhost>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	 <1291779177.32420.8.camel@maxim-laptop>
	 <20101208040559.20639.qmail@stuge.se>
	 <1291809485.5421.0.camel@maxim-laptop>  <20101212180916.71a57a71@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maxim Levitsky <maximlevitsky@gmail.com>,
	Peter Stuge <peter@stuge.se>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38037 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab0LLXFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 18:05:37 -0500
In-Reply-To: <20101212180916.71a57a71@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-12 at 18:09 +0100, Stefan Richter wrote:
> From: Maxim Levitsky <maximlevitsky@gmail.com>
> 
> To make userland, e.g. NetworkManager work with firewire, we need to
> detect whether cable is plugged or not.  Simple and correct way of doing
> that is just counting number of peers.  No peers - no link and vice
> versa.
[...]

NM doesn't use ETHTOOL_GLINK so you don't need to implement
ethtool_ops::get_link.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

