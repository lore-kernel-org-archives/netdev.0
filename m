From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Thu, 13 Jan 2005 01:36:25 +0100
Message-ID: <20050113003625.GJ14280@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <41E5A7E9.4030101@candelatech.com> <20050112224810.GE14280@xi.wantstofly.org> <41E5AEAC.8060706@candelatech.com> <20050112231615.GF14280@xi.wantstofly.org> <20050112234344.GM26856@postel.suug.ch> <20050113001837.GH14280@xi.wantstofly.org> <20050113002806.GN26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com,
        shemminger@osdl.org, shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050113002806.GN26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 01:28:06AM +0100, Thomas Graf wrote:

> > What's that?  I can't find it in my kernel tree nor on google.
> 
> Typo, sorry. I meant ip_tunnel_parm. Thinking of it, shouldn't protocol
> in ip_tunnel_parm->iph->protocol be set to ETHER_IP so userspace could
> find out this way?

ip_tunnel_parm->iph->protocol for ether/ip tunnels is IPPROTO_ETHERIP,
which is 97.  So yeah, the info is in there.  But this doesn't help you
much in determining whether an arbitrary network device is in fact an
ether/ip tunnel or not, since SIOCGETTUNNEL aliases with SIOCDEVPRIVATE+3.

The only way to make it stand out would be to give it its own ARPHRD_
type, but then it wouldn't look like an ethernet device anymore.


cheers,
Lennert
