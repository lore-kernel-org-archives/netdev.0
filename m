From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Thu, 13 Jan 2005 09:49:55 +0200 (EET)
Message-ID: <Pine.LNX.4.61.0501130944270.19573@netcore.fi>
References: <20050112222437.GC14280@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, shemminger@osdl.org, rhousley@rsasecurity.com,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050112222437.GC14280@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Jan 2005, Lennert Buytenhek wrote:
> After struggling with various userland VPN solutions for a while (and
> failing to make IPSEC tunnel mode do what I want), I decided to just
> implement ethernet-in-IP tunneling in the kernel and let IPSEC transport
> mode handle the rest.
>
> There appeared to be an RFC for ethernet-in-IP already, RFC 3378, so I
> just implemented that.  It's very simple -- slap a 16-bit header (0x3000,
> which is 4 bits of etherip version number and 12 bits of padding) onto
> the beginning of the ethernet packet, and then wrap it in an IP packet.

EtherIP is not recommended for use; it's an Informational RFC.

Is there a particular reason why GRE tunnel is not sufficient? 
AFAICS, it provides all the benefits of Ethernet-in-IP, is very 
commonly deployed, and only has 4 bytes of overhead.

And if GRE is not sufficient, the next step would be L2TP.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
