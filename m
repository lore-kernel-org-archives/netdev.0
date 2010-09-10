From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: [PATCH] IPv6: Change addrconf code to deal with link changes better
Date: Fri, 10 Sep 2010 23:27:48 +0100
Message-ID: <40oql7-6f5.ln1@chipmunk.wormnet.eu>
References: <4C8A9BF7.2090102@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46690 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991Ab0IJXIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Sep 2010 19:08:19 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OuChe-0003bJ-LX
	for netdev@vger.kernel.org; Sat, 11 Sep 2010 01:08:18 +0200
Received: from chipmunk.wormnet.eu ([195.195.131.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 11 Sep 2010 01:08:18 +0200
Received: from alex by chipmunk.wormnet.eu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 11 Sep 2010 01:08:18 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:
> 
> [snipped]
> 
> Change the IPv6 addrconf code to handle the case where the NIC link
> state goes UP-DOWN-UP by removing all the autoconfigured addresses
> when it goes down, so that when it comes back up they will get added
> again and DAD will be triggered.  
> 
Surely this is going to result in me sending you lots of rude emails 
everytime cursing you when my SSH connections are terminated for no real 
reason on a link flap?  Privacy addresses are handy on servers too such 
as DNS servers...

When on occasion I am forced to use Windows, those darn PuTTY disconnect 
popups I see each time I disconnect/connect from our wireless network 
nearly put axe swinging mood as it is.  Please, spare me experiencing 
this pain under Linux...

Of course I could be talking nonsense, so ignore this email and keep up 
the good work :)

Cheers

-- 
Alexander Clouter
.sigmonster says: Cole's Law:
                  	Thinly sliced cabbage.

