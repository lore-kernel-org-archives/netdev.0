From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Via Velocity minimum MTU size
Date: Mon, 22 May 2006 23:25:34 +0200
Message-ID: <20060522212534.GA23094@electric-eye.fr.zoreil.com>
References: <1148266609.2329.16.camel@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:10691 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751205AbWEVV2L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 17:28:11 -0400
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <1148266609.2329.16.camel@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn <jacliburn@bellsouth.net> :
[...]
> Can someone please explain why the driver might constrain the NIC to a
> minimum MTU size of 1500?

None that I remember of. The driver suffered some breakage when changing
the mtu while the interface is up but it has been fixed since february
(i.e. way before 2.6.16-1.2111_FC5).

>From a cursory glance at the documentation, I see no specific low limit
for the mtu. So... Does it break when you lower VELOCITY_MIN_MTU ?

-- 
Ueimor
