From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sat, 21 Jul 2007 17:14:31 +1000
Message-ID: <1185002071.6344.21.camel@localhost.localdomain>
References: <20070720.223129.59470764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46478 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756309AbXGUHPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 03:15:03 -0400
In-Reply-To: <20070720.223129.59470764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-20 at 22:31 -0700, David Miller wrote:
> Stephen asked me if I could resurrect the last version of
> his napi_poll patch that I posted a long time ago, I finally
> got to that tonight.
> 
> Basically, this disconnects the ->poll() object from the net
> device.  This will allow drivers to handle multi RX queues
> cleanly without creating fake net_device objects and crap
> like that.

Hi Dave,

	This looks good!  It might be nice though to go further and remove the
internal napi_struct.  It's kind of a wart for multi-queue drivers which
are going to have their own array (or whatever).

But I can do that as a separate patch if you think it's a decent idea.
The name "NAPI" is also a wart, but I guess it's everywhere now so one
more place isn't making things worse...

Cheers,
Rusty.


