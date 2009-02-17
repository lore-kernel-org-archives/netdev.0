From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 14:29:46 -0800 (PST)
Message-ID: <20090217.142946.232071526.davem@davemloft.net>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain>
	<20090217095232.5da06b9f@werewolf.home>
	<200902172001.41804.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: arvidjaar@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752451AbZBQWaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 17:30:03 -0500
In-Reply-To: <200902172001.41804.arvidjaar@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Borzenkov <arvidjaar@mail.ru>
Date: Tue, 17 Feb 2009 20:01:38 +0300

> Forward to bonding and netdev
 ...
> If IPv6 is disable in kernel config bonding loads. But I think it is 
> regression, it should be possible to disable IPv6 if not required.

Don't configure ipv6 into your kernel, really.

There is no other way to handle this.  If we want to support
IPV6 layer things in the bonding driver, it is going to
call helper functions in the ipv6 module and therefore must
be able to load it and use functions in it.
