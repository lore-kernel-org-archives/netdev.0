From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][RESEND] IPv6: Autoconfig link-local address on ip6-ip6
 tunnel device
Date: Wed, 7 Jan 2004 12:15:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040107121550.1dba9972.davem@redhat.com>
References: <Pine.LNX.4.58.0401071034440.27524@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0401071034440.27524@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jan 2004 11:22:57 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> This patch, made against cset 1.1492, adds a link-local address to a
> ip6-ip6 tunnel interface when it is brougth up.
> 
> It also changes the router solicitation behavior slightly by checking that
> rtr_solicits is > 0, before sending a router solicitation after a
> successful DAD probe on the link-local address.
> 
> 2.6.0 has been released, so would you apply this patch now? :)

Patch applied, thanks Ville.
