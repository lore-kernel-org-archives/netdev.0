From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 17 Jan 2005 23:04:48 +0100
Message-ID: <41EC3680.7060108@tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com> <1105363092.1041.146.camel@jzny.localdomain> <1105917038.1091.1041.camel@jzny.localdomain> <200501171404.19451.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200501171404.19451.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hasso Tepper wrote:
> All this work is done to avoid sending stale packets to the network? Ie. 
> there will be no change regarding socket blocking issue? Detecting carrier 
> on/off and/or socket per interface is must be for us in user space to avoid 
> socket blocking? I'm just trying to have full picture so I can put my 
> priorities in place for next release.

A proper solution would take care of both these issues: "stale packets"
and "socket blocking". They are pretty much related.

Using a socket for each interface *ought* not be needed.
Carrier detection sounds like a good thing in its own right.

Hope this helps,
Tommy
