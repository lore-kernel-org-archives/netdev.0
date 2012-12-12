From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Wed, 12 Dec 2012 10:12:08 -0800
Message-ID: <20121212101208.361ccda0@nehalam.linuxnetplumber.net>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
	<20121212081500.24085752@nehalam.linuxnetplumber.net>
	<20121212170520.GA3060@minipsycho.orion>
	<20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
	<20121212181017.GB3060@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43141 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754851Ab2LLSNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 13:13:24 -0500
In-Reply-To: <20121212181017.GB3060@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 19:10:17 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> ># ip li show dev dummy0
> >12: dummy0: <NO-CARRIER,BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state DORMANT mode DORMANT   
> 
> if you mean this "NO-CARRIER"
> it has no direct relation with netif_carrier_ok().

It is the same value (IFF_RUNNING) that is visible from user space.
