From: jamal <hadi@cyberus.ca>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
	in case forwarded frame has VLAN-header]
Date: 08 Mar 2005 16:43:41 -0500
Message-ID: <1110318221.1078.80.camel@jzny.localdomain>
References: <20050305141225.GA5180@xi.wantstofly.org>
	 <4229D98F.9010008@trash.net> <422A0C21.3050709@candelatech.com>
	 <1110199696.1094.1299.camel@jzny.localdomain>
	 <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>
	 <1110238537.1043.62.camel@jzny.localdomain>  <422CE983.7060305@trash.net>
	 <1110241190.1043.100.camel@jzny.localdomain>  <422D1E26.1010902@trash.net>
	 <1110287626.1043.146.camel@jzny.localdomain>
	 <422DE4B0.6040201@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <422DE4B0.6040201@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-08 at 12:45, Ben Greear wrote:
[..]
> jamal wrote:
> > I think you still want (perhaps the vlan) driver to come up with some
> > sane defaults. From what i read from bgrear he has arbitrary values.
> 
> By default, everything is mapped to priority of zero, but the user can
> specify a mapping to any integer they desire.
>
> If you have some suggestions for some defaults better than zero, I'm
> willing to consider it.
> 

Everything going to zero may not be such a bad default.
You could do better by creating a map that resembles what
the default 3 band scheduler does. Just keep in mind that  
the reverse semantics of priorities. If you need help we can take it
offline.

cheers,
jamal
