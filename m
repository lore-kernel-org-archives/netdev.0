From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH][Bonding]: keep slave state when admin down
Date: Thu, 03 Aug 2006 08:25:26 -0400
Message-ID: <1154607926.5205.8.camel@jzny2>
References: <1153401556.5098.43.camel@jzny2>
	 <200607201850.k6KIo0hg016751@death.nxdomain.ibm.com>
	 <1153426931.5273.136.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:56505 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932423AbWHCMZb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 08:25:31 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8cGb-0004IP-1A
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 08:25:33 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <1153426931.5273.136.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay,

I have tested with a standard bootup script - which amongst other things
brings down the bond and gives it a new MAC before bringing it up.

What do you wanna do with the patch? I know if it sits with me it will
be lost. 

cheers,
jamal

On Thu, 2006-20-07 at 16:22 -0400, jamal wrote:
> On Thu, 2006-20-07 at 11:50 -0700, Jay Vosburgh wrote:
> 
> > 
> > 	Do the initscript and sysconfig packages (/sbin/ifup, ifdown,
> > that stuff in /etc/sysconfig/network-scripts, etc) do the right thing
> > with this change?
> > 
> 
> I havent seen issues so far.
> 
> > 	If memory serves, the initscripts will down the bond during
> > setup; I'm not sure if there is any dependency on that action releasing
> > all (possibly preexisting) slaves.
> > 
> 
> The one i have experimented with has no issues - but you may be right
> some people depend on this behavior at shutdown.
> 
> > 	I don't have a big problem with this, but I'm a little concerned
> > that there may be dependencies on the existing behavior.
> 
> I could add a module parameter that restores old behavior when asked to
> and we keep that for a while and have it print a warning message.
> The other alternative is just release it and see if someone complains.
> 
> cheers,
> jamal

