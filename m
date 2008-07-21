From: David Miller <davem@davemloft.net>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 13:46:08 -0700 (PDT)
Message-ID: <20080721.134608.75595942.davem@davemloft.net>
References: <4884E6E6.7010800@lwfinger.net>
	<20080721.132100.128525904.davem@davemloft.net>
	<4884F3D7.4070604@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, ischram@telenet.be, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	j@w1.fi
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40831
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752853AbYGUUqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:46:08 -0400
In-Reply-To: <4884F3D7.4070604@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Mon, 21 Jul 2008 15:38:47 -0500

> David Miller wrote:
> > 
> > No further backtrace?  That will tell us what driver is causing
> > this.
> 
> Yes, I have a full backtrace.
> 
> It starts with possible recursive locking in NetworkManager, and goes directly 
> into the Warning - this came from a later pull of Linus's tree.

That helps a lot, I'm looking at this now.

Thanks.
