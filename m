From: Paul Smith <paul@mad-scientist.net>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying to
	ifenslave a second interface to my bond
Date: Wed, 15 Apr 2009 14:39:45 -0400
Message-ID: <1239820785.8944.604.camel@psmith-ubeta.netezza.com>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
	 <11276.1239757967@death.nxdomain.ibm.com>
	 <1239814602.8944.593.camel@psmith-ubeta.netezza.com>
	 <30789.1239819113@death.nxdomain.ibm.com>
Reply-To: paul@mad-scientist.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.netezza.com ([12.148.248.132]:60418 "EHLO netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753468AbZDOSju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 14:39:50 -0400
In-Reply-To: <30789.1239819113@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-15 at 11:11 -0700, Jay Vosburgh wrote:
>         The various MAC manipulating functions are either called under
> RTNL (as bond_alb_set_mac_address is) or take pains to acquire RTNL
> before doing anything with the MAC.  Also, the slave list and
> curr_active_slave are mutexed by RTNL, so those inspections should be
> safe.
> 
>         I'm reasonably sure that the curr_slave_lock is superfluous
> (which wasn't the case when it was originally introduced), but I
> haven't had a chance to validate this.  The locking has changed from
> what's documented in the header file; RTNL wasn't used for this when
> that was written.

OK, sounds good.  I'll let you know if I observe any other odd behavior
with the bonding driver.

Thanks for the great support!  Cheers!

-- 
Paul Smith <paul@mad-scientist.net>


