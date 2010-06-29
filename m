From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next-2.6 2/2] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Tue, 29 Jun 2010 08:39:32 +0200
Message-ID: <20100629063932.GA10072@secunet.com>
References: <20100624140057.GJ5570@secunet.com>
 <1277426759.26161.179.camel@localhost>
 <20100625082447.GK5570@secunet.com>
 <20100628.231812.35040625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	chase.douglas@canonical.com, nordmark@mech.kth.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38930 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363Ab0F2GiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 02:38:11 -0400
Content-Disposition: inline
In-Reply-To: <20100628.231812.35040625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 28, 2010 at 11:18:12PM -0700, David Miller wrote:
> 
> Once Ben posts a new version of this second patch with the
> proper spin_lock_init() calls added I am going to apply both
> of his changes.

Yes, of course apply them. It was just a recommendation to avoid the locks
in the cases they are not needed. These patches are a real improvement,
so I'm fine with them.

Steffen
