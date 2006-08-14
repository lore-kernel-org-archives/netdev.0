From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Mon, 14 Aug 2006 19:51:09 -0400
Message-ID: <1155599469.6946.46.camel@jzny2>
References: <20060814213718.580598840@postel.suug.ch>
	 <20060814214341.834971519@postel.suug.ch>  <1155598991.6946.42.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:27324 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932465AbWHNXvU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 19:51:20 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GCmDN-0006jP-L3
	for netdev@vger.kernel.org; Mon, 14 Aug 2006 19:51:25 -0400
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <1155598991.6946.42.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


CCing Hasso Tepper <hasso@estpak.ee>

Hasso, please comment on this thread (apologies, I forgot the other
guy's name; so if you can CC all the necessary suspects to comment, it
would help).

cheers,
jamal

On Mon, 2006-14-08 at 19:43 -0400, jamal wrote:
> On Mon, 2006-14-08 at 00:00 +0200, Thomas Graf wrote:
> > plain text document attachment (rtnl_convert_ip6_addr)
> > Fixes a wrong use of current->pid as netlink pid.
> 
> If i am not mistaken:
> Some of these removals of current->pid will affect users such as quagga,
> zebra, vrrpd etc. If those specific users are not affected, please
> ignore the rest of my comments.
> 
> I realize mr. Kuznetsov submitted at least one patch in the past to do
> something similar to this. 
> IMO, I believe there is a strong case that can be made for events that
> were caused by non-netlink users such as ioctls that could at least be
> multicast with current->pid. In other words an exception case for only
> this scenario. In such a case there is no unicast netlink message. 
> It would also be acceptable if the quagga etc folks could meet their
> goals some other way.
> 
> cheers,
> jamal
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

