From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] ethtool: Report link-down while
 interface is down
Date: Fri, 10 Dec 2010 15:55:59 -0800 (PST)
Message-ID: <20101210.155559.55870093.davem@davemloft.net>
References: <1291932515.2647.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750929Ab0LJXzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:55:31 -0500
In-Reply-To: <1291932515.2647.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 09 Dec 2010 22:08:35 +0000

> While an interface is down, many implementations of
> ethtool_ops::get_link, including the default, ethtool_op_get_link(),
> will report the last link state seen while the interface was up.  In
> general the current physical link state is not available if the
> interface is down.
> 
> Define ETHTOOL_GLINK to reflect whether the interface *and* any
> physical port have a working link, and consistently return 0 when the
> interface is down.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> David,
> 
> I know you weren't keen on this, but if you don't accept it then please
> say what you think the proper semantics are.

No, I'm actually fine with this.

Applied, thanks Ben!
