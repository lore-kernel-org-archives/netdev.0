From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Wed, 3 Nov 2004 16:07:27 -0800
Message-ID: <20041103160727.54dc0c15.davem@davemloft.net>
References: <20041030030936.GA25102@lists.us.dell.com>
	<1099163419.1039.97.camel@jzny.localdomain>
	<20041101044433.GA18772@lists.us.dell.com>
	<20041101173434.GA12437@lists.us.dell.com>
	<20041101202754.GA23149@gondor.apana.org.au>
	<20041101203821.GA15086@lists.us.dell.com>
	<20041101204131.GA23277@gondor.apana.org.au>
	<20041101204533.GA17279@lists.us.dell.com>
	<1099345849.1073.1.camel@jzny.localdomain>
	<20041101215944.GB17279@lists.us.dell.com>
	<20041101220644.GA23903@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matt_Domsch@dell.com, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041101220644.GA23903@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Nov 2004 09:06:44 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Nov 01, 2004 at 03:59:44PM -0600, Matt Domsch wrote:
> > 
> > Actually, -EOVERFLOW appears throughout the kernel.  A couple examples:
> 
> I agree.  Please disregard my comment re ERANGE.

I think there is nothing wrong with clearing out the buffer
for the !dev->addr_len case.  This is not to say that what
the apps are doing is correct or not, it merely preserves
2.4.x behavior which was changed unintentionally.

I'm going to apply Matt's patch which began this thread.
