From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Thu, 13 Jan 2005 01:28:06 +0100
Message-ID: <20050113002806.GN26856@postel.suug.ch>
References: <20050112222437.GC14280@xi.wantstofly.org> <41E5A7E9.4030101@candelatech.com> <20050112224810.GE14280@xi.wantstofly.org> <41E5AEAC.8060706@candelatech.com> <20050112231615.GF14280@xi.wantstofly.org> <20050112234344.GM26856@postel.suug.ch> <20050113001837.GH14280@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com,
        shemminger@osdl.org, shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20050113001837.GH14280@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Lennert Buytenhek <20050113001837.GH14280@xi.wantstofly.org> 2005-01-13 01:18
> What's that?  I can't find it in my kernel tree nor on google.

Typo, sorry. I meant ip_tunnel_parm. Thinking of it, shouldn't protocol
in ip_tunnel_parm->iph->protocol be set to ETHER_IP so userspace could find out
this way?
