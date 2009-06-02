From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Multicast socket option
Date: Tue, 02 Jun 2009 00:45:34 -0700 (PDT)
Message-ID: <20090602.004534.165425108.davem@davemloft.net>
References: <4A1EC33E.1080201@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com, cl@linux.com
To: niv@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757071AbZFBHpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:45:34 -0400
In-Reply-To: <4A1EC33E.1080201@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nivedita Singhvi <niv@us.ibm.com>
Date: Thu, 28 May 2009 10:00:46 -0700

> After some discussion offline with Christoph Lameter and David Stevens
> regarding multicast behaviour in Linux, I'm submitting a slightly
> modified patch from the one Christoph submitted earlier.
> 
> This patch provides a new socket option IP_MULTICAST_ALL.
> 
> In this case, default behaviour is _unchanged_ from the current
> Linux standard. The socket option is set by default to provide
> original behaviour. Sockets wishing to receive data only from
> multicast groups they join explicitly will need to clear this socket
> option.
> 
> 
> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
> Signed-off-by: Christoph Lameter<cl@linux.com>
> Acked-by: David Stevens <dlstevens@us.ibm.com>

Applied, thanks.
