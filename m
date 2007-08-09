From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: myri10ge net-2.6.24 build fix
Date: Thu, 09 Aug 2007 09:30:33 -0400
Message-ID: <46BB16F9.6030402@myri.com>
References: <20070809.001138.39464000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1944 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S939231AbXHINag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 09:30:36 -0400
In-Reply-To: <20070809.001138.39464000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
 > I had to add the following patch to fix the build after
 > the LRO changes, I have no idea how you could have compile
 > tested that patch let alone done any real testing on it :-/

Whoops.  I'm very sorry about that.  Future patches will be submitted
by our Linux guy, who knows the correct procedures. :)

FWIW, the patch I sent came from a script which filters our internal
driver (which I always work with), and that line was erroneously
filtered by the script we use to remove all the stuff you guys frown
on (like our LRO, compat shims for older kernels, optional support to
receive into skbs rather than pages, etc).  My testing was done with
our un-filtered upstream driver.

Since our driver specific LRO is now gone (hurray!), I removed the LRO
filtering, re-ran the filter script, and arrived at the same patch
you committed.

Thanks for fixing my mistake!

Drew


