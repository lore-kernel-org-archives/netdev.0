From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Thu, 13 Jan 2005 01:18:37 +0100
Message-ID: <20050113001837.GH14280@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <41E5A7E9.4030101@candelatech.com> <20050112224810.GE14280@xi.wantstofly.org> <41E5AEAC.8060706@candelatech.com> <20050112231615.GF14280@xi.wantstofly.org> <20050112234344.GM26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com,
        shemminger@osdl.org, shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050112234344.GM26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 12:43:44AM +0100, Thomas Graf wrote:

> > > >>Also, could you add an ioctl that allowed one to query whether or not
> > > >>a particular device is an etherip device?  I had always wished I had added
> > > >>this earlier to the VLAN code :)
> > > >
> > > >Hmmm.  Bridge devices don't have this either, do they?  Can you name
> > > >an advantage of having this?
> > > 
> > > I got the request several times with regard to VLANs.  Lots of people
> > > (and applications) will want to know the interface type for various
> > > reasons.  If you don't give them a nice programatic thing like an
> > > IOCTL to call, they will undoubtedly start making assumptions based
> > > off of the device name...
> > 
> > Makes sense..
> > 
> > Unfortunately SIOCGETTUNNEL is (SIOCDEVPRIVATE + 3), otherwise we could
> > just say something like "If an ARPHRD_ETHER device supports SIOCGETTUNNEL,
> > it's an ether/ip tunnel."
> > 
> > Any better ideas?  I hate adding more ioctls.
> 
> I think it should go into ip_tunnel_param, unforunately there are no
> unused fields.

What's that?  I can't find it in my kernel tree nor on google.


> Maybe schedule this for 2.7 together with a clean up
> of all the tunnels so they share redundant code? Lots of gre related
> code and comments spread over non-gre tunnels that should go away.

Indeed, it would be good to have this cleaned up.


cheers,
Lennert
