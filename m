From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.19/2.6.20 BUG in inet_rtm_newaddr()/__inet_insert_ifa()
Date: Sat, 10 Mar 2007 16:19:17 +0300
Message-ID: <20070310131917.GA25794@2ka.mipt.ru>
References: <20070309103333.GA17232@janus> <20070309123016.GA4736@2ka.mipt.ru> <20070309182236.GA21587@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42781 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933247AbXCJNTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2007 08:19:23 -0500
Content-Disposition: inline
In-Reply-To: <20070309182236.GA21587@janus>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2007 at 07:22:36PM +0100, Frank van Maarseveen (frankvm@frankvm.com) wrote:
> Ok that worked.. not as I expected. I don't understand the EINVAL and
> "ip addr" shows no broadcast address for eth0 when a classless address is
> added as the primary (and only) address like in the above example. That's
> why I tried to set it manually in the second "ip" command.

Because you might want not 

ip addr add 172.18.12.99/21 dev dummy0
ip addr add broadcast 172.18.15.255 dev dummy0

but 

ip addr add 172.18.12.99/21 broadcast 172.18.15.255 dev dummy0

Magic of local/global adresses is hidden here.

> -- 
> Frank
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
