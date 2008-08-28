From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: 2.6.27-rc ... iwl3945 regression?
Date: Thu, 28 Aug 2008 16:41:34 +0200
Message-ID: <20080828164134.1cd3bb12@hskinnemo-gx745.norway.atmel.com>
References: <200808131735.42451.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpeu1.atmel.com ([195.65.72.27]:49950 "EHLO bagnes.atmel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830AbYH1Olw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 10:41:52 -0400
In-Reply-To: <200808131735.42451.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell <david-b@pacbell.net> wrote:
> Does this sound familiar to anyone?  Got a fix that's better than
> sticking to a 2.6.26 kernel?  :)

FWIW, I'm seeing the same thing with -rc4 and the b43 driver, so it's
probably not a regression in iwl3945. I guess it could be something in
mac80211?

I'm currently working around it by manually running iwconfig while
nm-applet is bringing the interface up. A bit annoying, but it
works...and it indicates that the driver works fine, but NetworkManager
doesn't know that it's supposed to do any wireless configuration before
bringing the interface up.

Haavard
