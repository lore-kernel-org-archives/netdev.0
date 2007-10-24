From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Cleanup the IPv6 addresses printing in /proc files
Date: Tue, 23 Oct 2007 21:18:52 -0700 (PDT)
Message-ID: <20071023.211852.15263990.davem@davemloft.net>
References: <1193198641.11845.49.camel@localhost>
	<20071023.211045.23014439.davem@davemloft.net>
	<1193199336.11845.53.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751752AbXJXETH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 00:19:07 -0400
In-Reply-To: <1193199336.11845.53.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 23 Oct 2007 21:15:36 -0700

> On Tue, 2007-10-23 at 21:10 -0700, David Miller wrote:
> > We'll break things if we change it.
> 
> Maybe, but definitely the macro names should
> reflect this brokenness.

That's a good point, we don't want to encourage further
use of these things.

Pavel, I'm going to revert this patch for now.  It may
save some code lines, but it does so at the expense of
creating an interface we actually don't want more users
of.
