From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: TCP Persist Timer DoS
Date: Sat, 20 Jun 2009 02:11:00 -0700
Message-ID: <20090620091100.GB22935@mail.oracle.com>
References: <20090619223106.GJ29140@mail.oracle.com>
 <20090620.010514.46602476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:59643 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbZFTJMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 05:12:22 -0400
Content-Disposition: inline
In-Reply-To: <20090620.010514.46602476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2009 at 01:05:14AM -0700, David Miller wrote:
> From: Joel Becker <Joel.Becker@oracle.com>
> Date: Fri, 19 Jun 2009 15:31:06 -0700
> 
> > Hey Netfolk,
> > 	I have to assume you've seen
> > http://www.phrack.org/issues.html?issue=66&id=9&mode=txt.  Does anyone
> > have a plan or opinion on the DoS?  A way to mitigate it, a -EDONTCARE
> > opinion, anything?
> 
> This is just like every other "DoS" out there where the attacker has
> to reveal it's IP identity to accomplish the attack, in that it is
> trivial to protect using netfilter by limiting the number of
> connections a host can make with your system.

	Thanks Dave, I knew there was a reason this wasn't all that
scary.

Joel

-- 

"Hell is oneself, hell is alone, the other figures in it, merely projections."
        - T. S. Eliot

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
