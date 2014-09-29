From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 29 Sep 2014 21:03:19 +0200
Message-ID: <1412017399.14757.4.camel@localhost>
References: <52EFFE20.5080500@candelatech.com>
	 <20140203220323.GB17999@order.stressinduktion.org>
	 <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com>
	 <20140208172310.GF16198@order.stressinduktion.org>
	 <loom.20140926T001736-777@post.gmane.org>
	 <1411906297.2400343.172598909.66223582@webmail.messagingengine.com>
	 <loom.20140929T195637-887@post.gmane.org>
	 <5429A886.1040809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hongmei Li <duckcncn@gmail.com>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45180 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750906AbaI2TM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:12:57 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 5583A20435
	for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 15:03:21 -0400 (EDT)
In-Reply-To: <5429A886.1040809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2014-09-29 at 11:44 -0700, Ben Greear wrote:
> On 09/29/2014 11:15 AM, Hongmei Li wrote:
> > Thanks Hannes for your prompt response!
> > 
> > We just encountered this issue two times in our product stability test so far,
> > and my panic backtrace is the exactly same with the one reported here.
> > I don't know how to reproduce the issue till now. 
> > I tried several method, unfortunately, I can not reproduce it by myself. :(
> 
> We could reproduce it easily using our user-space tool that creates 1000
> mac-vlans, configures them, dumps routing tables, etc.  But, we could
> only reproduce it when we had the ixgbe ports unplugged.  If they
> were properly connected to a switch, we did not see any crashes.
> 
> My original email on 2/3/2014 has more details, and the thread that
> follows has some info on debugging we did at the time.

I just tried to reproduce the problem, disabling the port on a switch
and setting up 1000 macvlans on a ixgbe, enabling ipv6 and dumping
routing tables. Unluckily I had no success. :(

Any more hints?

Bye,
Hannes
