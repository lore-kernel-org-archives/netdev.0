From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] kernel bug at dev.c:4021
Date: Fri, 07 Nov 2008 23:33:40 -0800 (PST)
Message-ID: <20081107.233340.253702625.davem@davemloft.net>
References: <20081107154407.43165cc4@osprey.hogchain.net>
	<20081107223907.GA18677@x200.localdomain>
	<20081107170711.2b12189c@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: jacliburn@bellsouth.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbYKHHdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 02:33:41 -0500
In-Reply-To: <20081107170711.2b12189c@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Fri, 7 Nov 2008 17:07:11 -0600

> On Sat, 8 Nov 2008 01:39:07 +0300
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > Do git-revert ae33bc40c0d96d02f51a996482ea7e41c5152695 meanwhile.
> 
> Yep, that was it.  Thanks Alexey.

I've fixed this up in my tree so the next linux-next should not
have this problem.
