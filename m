From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Sun, 18 Dec 2011 09:40:24 -0500
Message-ID: <4EEDFB58.20904@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org> <20111217.215630.640392276998191183.davem@davemloft.net> <4EED6DED.50308@gentoo.org> <20111218.001925.2108645748994734084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:52442
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751556Ab1LROkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 09:40:41 -0500
In-Reply-To: <20111218.001925.2108645748994734084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2011 00:19, David Miller wrote:

> From: Joshua Kinard <kumba@gentoo.org>
> Date: Sat, 17 Dec 2011 23:37:01 -0500
> 
>> MACE Ethernet only ever appears on the SGI O2 systems.
> 
> That has no bearing on my feedback, we simply do not put non-portable
> code like this into the tree at this point.
> 
> Just because this driver has been maintained in an non-portable manner
> up to this point, doesn't mean we continue doing that.


Agreed.  However, I was simply trying to fix a problem that prevents IPv6
from working, not fix every little thing wrong with the code.  While I want
to tackle re-writing the driver to be more in line with existing network
drivers, that's a future project.  I'm still new to driver
development/kernel work in general, so I'm learning here.


Thanks for the feedback, though,

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic
