From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPsec: add support for Twofish and Serpent
Date: Thu, 14 Aug 2003 19:12:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814191259.435945cf.davem@redhat.com>
References: <20030814180857.GA4205@netppl.fi>
	<Pine.LNX.4.44.0308142324310.29579-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pp@netppl.fi, kyle@debian.org, jmorris@intercode.com.au,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0308142324310.29579-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 14 Aug 2003 23:25:11 +0300 (EEST)
Pekka Savola <pekkas@netcore.fi> wrote:

> Very much agree.

I totally disagree, choice is everything.

That's why we allow NULL crypto algorithms.  Not doing
so turns this into a political thing, which I decidedly
do not want our IPSEC implementation to be all about.

And therefore I will add the patch.

> Also, I could be missing something, but I think it takes much more to add 
> an encryption algorithm than what the patch does?!?!

If you use the netlink based IPSEC implementation, any crypto
algorithm is supported fully the moment it is added to crypto/.

When using pfkeyv2 sockets, yes you have to assign a number and then
the APP has to be aware of it.  This just shows how bogus it is to use
fixed numbers instead of strings to select crypto algorithms.
