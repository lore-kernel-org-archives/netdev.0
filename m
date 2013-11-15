From: David Miller <davem@davemloft.net>
Subject: Re: [OOPS][3.12] BUG: unable to handle kernel NULL pointer
 dereference at 0000000c
Date: Fri, 15 Nov 2013 18:57:55 -0500 (EST)
Message-ID: <20131115.185755.1752342950675745464.davem@davemloft.net>
References: <CAErSpo4jh7pO=jhZTvHD+sT2O12Ly6V3e_oiac8gHqmdmqevkg@mail.gmail.com>
	<20131115.174426.1448825246187940374.davem@davemloft.net>
	<20131115233919.GB11450@pomac.netswarm.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, pomac@vapor.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org, alex.aring@gmail.com,
	steffen.klassert@secunet.com
To: pomac@demius.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60573 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab3KOX57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 18:57:59 -0500
In-Reply-To: <20131115233919.GB11450@pomac.netswarm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Kumlien <pomac@demius.net>
Date: Sat, 16 Nov 2013 00:39:19 +0100

> On Fri, Nov 15, 2013 at 05:44:26PM -0500, David Miller wrote:
>> From: Bjorn Helgaas <bhelgaas@google.com>
>> Date: Fri, 15 Nov 2013 15:29:53 -0700
>> 
>> > [+cc David, Eric, Alex, netdev]
>> > 
>> > Alex reported a similar issue at
>> > http://marc.info/?l=linux-netdev&m=138355719901790&w=4
>> 
>> Fixed by:
>> 
>> commit 84502b5ef9849a9694673b15c31bd3ac693010ae
>> Author: Steffen Klassert <steffen.klassert@secunet.com>
>> Date:   Wed Oct 30 11:16:28 2013 +0100
> 
> Cherry-picked, compiled and preparing for reboot - thanks!
> 
> Shouldn't this be queued up in stable sometime soonish?
> 
> (Sorry for the change of email address, i had forgot to switch the
> configurations in mutt)

Steffen is in charge of IPSEC -stable submissions, please ask him
:-)
