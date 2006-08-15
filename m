From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Tue, 15 Aug 2006 05:50:54 -0400
Message-ID: <1155635455.6946.94.camel@jzny2>
References: <20060814213718.580598840@postel.suug.ch>
	 <1155598991.6946.42.camel@jzny2> <1155599469.6946.46.camel@jzny2>
	 <200608151020.26836.hasso@estpak.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:45747 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S965340AbWHOJvB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 05:51:01 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GCvZe-0004MU-6N
	for netdev@vger.kernel.org; Tue, 15 Aug 2006 05:51:02 -0400
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200608151020.26836.hasso@estpak.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-15-08 at 10:20 +0300, Hasso Tepper wrote:

> Zebra, Quagga and Xorp treat the pid field in the netlink header as 
> unicast address of the netlink socket. As far as I know, that was the 
> original idea:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=113943269432327&w=2
> 
> So, for Zebra, Quagga and Xorp users removals of current->pid mean just 
> closing potential races. You can't quarantee that ip/route/ifconfig will 
> not have the pid equal to the address of the netlink socket 
> Zebra/Quagga/Xorp owns.

We've had this discussion before, havent we? ;-> Why do people like
Alexey remember but i dont ;-> In any case if you are happy, I am happy
too and i hope this settles it then ;->

cheers,
jamal

