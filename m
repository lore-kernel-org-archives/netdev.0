From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Mon, 02 Feb 2009 12:05:07 -0800 (PST)
Message-ID: <20090202.120507.152093960.davem@davemloft.net>
References: <20090128.122924.106238702.davem@davemloft.net>
	<alpine.LSU.2.00.0901300510310.22910@fbirervta.pbzchgretzou.qr>
	<4986CC6D.4090904@walrond.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, sam@ravnborg.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: andrew@walrond.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38643
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753011AbZBBUFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 15:05:11 -0500
In-Reply-To: <4986CC6D.4090904@walrond.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Walrond <andrew@walrond.org>
Date: Mon, 02 Feb 2009 10:35:25 +0000

> Hey guys. A gentle nudge...
> 
> My distro scripts build the
> 
>     glibc
>     iproute2
>     iputils
>     kbd
>     lm_sensors
>     net-tools
>     strace
> 
> packages and others against every new release of linux and linux-stable, (hence my initial report).
> Right now I'm stalled at the 2.6.27.? headers so can't do any more testing until this is resolved.

There isn't anything we can really do about these cases.

No matter what we do, we break the userland build in one way or
another.
