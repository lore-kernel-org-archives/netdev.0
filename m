From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not
 equal to /proc/sys/net/ipv4/tcp_syn_retries
Date: Mon, 27 Sep 2010 01:10:46 -0700 (PDT)
Message-ID: <20100927.011046.45906887.davem@davemloft.net>
References: <20100922020212.d2aaec57.akpm@linux-foundation.org>
	<20100924.200557.229751150.davem@davemloft.net>
	<201009271007.06705.yuri@itinteg.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, damian@tvk.rwth-aachen.de
To: yuri@itinteg.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45432
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752310Ab0I0IK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 04:10:26 -0400
In-Reply-To: <201009271007.06705.yuri@itinteg.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuri Chislov <yuri@itinteg.net>
Date: Mon, 27 Sep 2010 10:07:06 +0200

>   It looks like the behavior changed in 2.6.32. 2.6.32 and up, uses some 
> calculation instead of a direct definition of the retries number, that makes it 
> harder to achieve the necessary system behavior.
> 
>  The default behavior of the system changed completely
> (the old default connect timeout was ~ 180 seconds, while the new one is ~21 
> sec). 
> 
> The new behavior invalidates the kernel documentation and tcp man page.
> 
> It's not possible to set a connect timeout > 25 sec in the applications while 
> using the default values in /proc. 
> 
> From my view point is regression.

Agreed, Damian you have to fix this.

Otherwise I'm reverting all of your Revert Backoff commits.
