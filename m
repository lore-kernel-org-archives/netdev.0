From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Fri, 22 Jun 2007 14:38:07 +0200
Message-ID: <467BC2AF.8080901@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62700 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034AbXFVMio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 08:38:44 -0400
In-Reply-To: <ygfk5tw41rq.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> 
>>Is there a reason why you're still doing the "allocate n devices
>>on init" thing instead of using the rtnl_link API?
> 
> 
> Sorry, it's simply a matter of time.  We have been extremely busy with
> other projects and two presentations (mgmt, customers, and press) the
> last two weeks and have worked on the other changes this week.  I'm
> sorry I haven't yet been able to look at your rtnl_link code close
> enough, but it's definitely on my todo list.  Starting on Sunday I'll
> be on a business trip to .jp for a week, and I hope I get to it in
> that week, otherwise on return.


Sorry, but busy is no reason for merging code that has deprecated
(at least by me :)) behaviour. Please change this before submitting
for inclusion.

