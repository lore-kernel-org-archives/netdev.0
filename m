From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Thu, 13 Jan 2005 00:16:15 +0100
Message-ID: <20050112231615.GF14280@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <41E5A7E9.4030101@candelatech.com> <20050112224810.GE14280@xi.wantstofly.org> <41E5AEAC.8060706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, shemminger@osdl.org, shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <41E5AEAC.8060706@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2005 at 03:11:40PM -0800, Ben Greear wrote:

> >>Also, could you add an ioctl that allowed one to query whether or not
> >>a particular device is an etherip device?  I had always wished I had added
> >>this earlier to the VLAN code :)
> >
> >Hmmm.  Bridge devices don't have this either, do they?  Can you name
> >an advantage of having this?
> 
> I got the request several times with regard to VLANs.  Lots of people
> (and applications) will want to know the interface type for various
> reasons.  If you don't give them a nice programatic thing like an
> IOCTL to call, they will undoubtedly start making assumptions based
> off of the device name...

Makes sense..

Unfortunately SIOCGETTUNNEL is (SIOCDEVPRIVATE + 3), otherwise we could
just say something like "If an ARPHRD_ETHER device supports SIOCGETTUNNEL,
it's an ether/ip tunnel."

Any better ideas?  I hate adding more ioctls.


cheers,
Lennert
