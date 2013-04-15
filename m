From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Build error v3.9-rc when CONFIG_IPV6 configured as module
Date: Mon, 15 Apr 2013 11:05:29 +0200
Message-ID: <1366016729.8361.4.camel@jlt4.sipsolutions.net>
References: <CACraW2pBKzCfpORkERDGddvguCWai3j49uM7rHLja0QTREkg4w@mail.gmail.com>
	 (sfid-20130414_114618_800925_33CBD969) <1366016535.8361.2.camel@jlt4.sipsolutions.net>
	 <1366016677.8361.3.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tomas Melin <tomas.melin@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:48934 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932703Ab3DOJFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 05:05:35 -0400
In-Reply-To: <1366016677.8361.3.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 11:04 +0200, Johannes Berg wrote:

> > Oops, I didn't realize that IPv6 could even (still) be built as a
> > module. I'll add this to mac80211's Kconfig:
> > 	depends on IPV6 || !IPV6
> > to fix this.
> 
> Hm, actually, that's not sufficient since there are no no-op versions of
> these functions when IPv6 isn't built ... needs a bit more.

Oh, never mind, I already handle that case ... Should check the code
before :)

johannes
