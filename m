From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][KEY]: Convert net/pfkey to use seq files.
Date: Sat, 09 Feb 2008 23:21:01 -0800 (PST)
Message-ID: <20080209.232101.94186105.davem@davemloft.net>
References: <47AC478E.3070507@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757894AbYBJHUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:20:30 -0500
In-Reply-To: <47AC478E.3070507@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 08 Feb 2008 15:14:06 +0300

> The seq files API disposes the caller of the difficulty of
> checking file position, the length of data to produce and
> the size of provided buffer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, but this kind of stuff is borderline wrt. the
"no new features" declaration.

Please queue future instances of this kind of stuff for when I open up
net-2.6.26, thanks.
