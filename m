From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Thu, 30 Jan 2014 19:12:29 +0100
Message-ID: <20140130181229.GA32245@sesse.net>
References: <20140118191107.GA21979@sesse.net>
 <20140119181806.GC16462@order.stressinduktion.org>
 <20140120184025.GA19972@sesse.net>
 <20140130104709.GA21178@sesse.net>
 <20140130180304.GA3793@plex.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:41490 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298AbaA3SMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 13:12:34 -0500
Content-Disposition: inline
In-Reply-To: <20140130180304.GA3793@plex.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 04:08:11PM -0200, Flavio Leitner wrote:
> No special multicast route, so it should go out on em1/default route.

Well, that's not really relevant for my bug then, is it? My problem is that
it goes out on the default unicast route, whereas it shouldn't.

> Maybe your application is using wrong values to IP_MULTICAST_IF?
> strace and /proc/net/igmp as suggested might help you find out.

This goes for at least vlc+mplayer+xbmc. I don't think they would all be
buggy in the same way? (Actually I don't think any of them set
IP_MULTICAST_IF.)

/* Steinar */
-- 
Homepage: http://www.sesse.net/
