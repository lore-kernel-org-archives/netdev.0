From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 23:58:51 -0700 (PDT)
Message-ID: <20090421.235851.160519606.davem@davemloft.net>
References: <20090422064159.GA4221@bx9.net>
	<20090421.234618.181879214.davem@davemloft.net>
	<20090422065443.GC4221@bx9.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: greg@blekko.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53680
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbZDVG67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 02:58:59 -0400
In-Reply-To: <20090422065443.GC4221@bx9.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Lindahl <greg@blekko.com>
Date: Tue, 21 Apr 2009 23:54:43 -0700

> On Tue, Apr 21, 2009 at 11:46:18PM -0700, David Miller wrote:
> 
>> If overly anal apps "code for it" that is entirely besides the point.
>> What we have to be concerned for, from a kernel behavioral standpoint,
>> is that some apps "might not code for it".  This is why we don't
>> change behavior.
> 
> I am suggesting that you survey actual apps. If you find that they're
> all overly anal, then maybe you've learned something about EAGAIN
> already happening today. I assure you that the co-worker who stuck in
> the "ignore EAGAIN without logging it" only did so because he saw it
> fairly frequently. He's that way.

It's likely a bug and should have been reported.

Unexplainable behavior isn't something to ignore.

