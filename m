From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: v6-in-v4 IPsec and NAT traversal
Date: Sat, 13 Mar 2004 14:53:44 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403131452280.25018-100000@netcore.fi>
References: <E1B261p-0006gI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1B261p-0006gI-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 13 Mar 2004, Herbert Xu wrote:
> Pekka Savola <pekkas@netcore.fi> wrote:
> > I'm interested whether Linux IPsec implementations support:
> > 
> > 1) IPv6 payload inside IPv4 IPsec tunnel/transport?
> 
> It's not supported directly by the IPsec stack.  However, you can
> setup an SIT tunnel over a transport IPv4 IPsec SA.

Is this planned?  Are there issues with "native" support why it would 
not be feasible?

Avoiding double encapsulation would be IMHO really useful, and several 
other implementations are already reported to allow this.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
