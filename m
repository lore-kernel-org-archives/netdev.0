From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Wed, 3 Nov 2004 21:42:42 -0600
Message-ID: <20041104034241.GA26300@lists.us.dell.com>
References: <20041101044433.GA18772@lists.us.dell.com> <20041101173434.GA12437@lists.us.dell.com> <20041101202754.GA23149@gondor.apana.org.au> <20041101203821.GA15086@lists.us.dell.com> <20041101204131.GA23277@gondor.apana.org.au> <20041101204533.GA17279@lists.us.dell.com> <1099345849.1073.1.camel@jzny.localdomain> <20041101215944.GB17279@lists.us.dell.com> <20041101220644.GA23903@gondor.apana.org.au> <20041103160727.54dc0c15.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103160727.54dc0c15.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 03, 2004 at 04:07:27PM -0800, David S. Miller wrote:
> On Tue, 2 Nov 2004 09:06:44 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Mon, Nov 01, 2004 at 03:59:44PM -0600, Matt Domsch wrote:
> > > 
> > > Actually, -EOVERFLOW appears throughout the kernel.  A couple examples:
> > 
> > I agree.  Please disregard my comment re ERANGE.
> 
> I think there is nothing wrong with clearing out the buffer
> for the !dev->addr_len case.  This is not to say that what
> the apps are doing is correct or not, it merely preserves
> 2.4.x behavior which was changed unintentionally.
> 
> I'm going to apply Matt's patch which began this thread.

If it's all the same to you, I prefer the last version.  If you want
to remove the net_ratelimited printk, that would be fine too.  Either
way the apps will work as expected again.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
