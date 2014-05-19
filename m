From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] ISDN patches for net-next
Date: Sun, 18 May 2014 21:36:07 -0400 (EDT)
Message-ID: <20140518.213607.1866002359122979029.davem@davemloft.net>
References: <cover.1400448368.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pebolle@tiscali.nl,
	isdn4linux@listserv.isdn4linux.de, isdn@linux-pingi.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbaESBgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 21:36:09 -0400
In-Reply-To: <cover.1400448368.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun, 18 May 2014 23:26:08 +0200

> Here's a series of patches for the ISDN CAPI subsystem and an auxiliary
> patch to the tty driver, prepared by Paul Bolle over the last couple of
> weeks. I would appreciate if you could merge these via net-next.

Since this has been broken for several years, you might be doing more
harm than good by trying to change things back again.

Why not just have capiplugin able to search for and use the names
generated now?

That way it will work on any kernel version and/or combination with
udev.

I'm not really excited to apply this series, I genuinely think it
makes things worse, sorry.
