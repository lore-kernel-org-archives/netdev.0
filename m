From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Fix sysctl restarts...
Date: Fri, 19 Feb 2010 15:29:54 -0800 (PST)
Message-ID: <20100219.152954.39315470.davem@davemloft.net>
References: <m14olcu7xo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55475
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756318Ab0BSX3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:29:37 -0500
In-Reply-To: <m14olcu7xo.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 19 Feb 2010 15:22:59 -0800

> 
> Yuck.  It turns out that when we restart sysctls we were restarting
> with the values already changed.  Which unfortunately meant that
> the second time through we thought there was no change and skipped
> all kinds of work, despite the fact that there was indeed a change.
> 
> I have fixed this the simplest way possible by restoring the changed
> values when we restart the sysctl write.
> 
> One of my coworkers spotted this bug when after disabling forwarding
> on an interface pings were still forwarded.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

What commit added this bug?
