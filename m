From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Tue, 24 Aug 2010 18:28:44 +0200
Message-ID: <20100824162844.GA7889@nuttenaction>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
 <1282632262.2378.1681.camel@edumazet-laptop>
 <4C737D15.5060400@nets.rwth-aachen.de>
 <423116d1d215b0fb3d1c966fb8167508@localhost>
 <4C73DE32.1030802@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"H.K. Jerry Chu" <hkchu@google.com>, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net, netdev@vger.kernel.org
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:53811 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755447Ab0HXQ24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 12:28:56 -0400
Content-Disposition: inline
In-Reply-To: <4C73DE32.1030802@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Hannemann | 2010-08-24 16:58:58 [+0200]:

>Nice, so did you come up with a name for the socket option yet?

+#define      TCP_UTO       18  /* User Timeout Option */

The patch is an early state and details as well as testing is a little bit
costly.

>Hmm, is there really a difference? If an application specifies
>a wanted timeout e.g. with USER_TIMEOUT, CHANGEABLE will
>become false and the value would be announced via ADV_UTO.
>The connection could be aborted locally after that time passed,
>regardless of what the remote site thinks the timeout should be.
>
>As I understand it U_LIMIT and L_LIMIT would only be there
>for safety to disallow nonsensical values of USER_TIMEOUT.
>
>Did I miss something?

Maybe not, aot sure. I must take a look at the patch from Jerry. I had no time
until now.

Hagen
