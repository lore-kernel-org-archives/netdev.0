From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become
 free. Usage count = 1
Date: Sun, 13 Jun 2004 21:07:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040613210725.70dbd016.davem@redhat.com>
References: <20040613121514.6b3c1c8a.davem@redhat.com>
	<E1BZeW1-0008Ny-00@gondolin.me.apana.org.au>
	<20040613234142.GA32329@gondor.apana.org.au>
	<20040613183622.3a814506.davem@redhat.com>
	<20040614015013.GA11048@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040614015013.GA11048@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jun 2004 11:50:13 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, Jun 13, 2004 at 06:36:22PM -0700, David S. Miller wrote:
> > On Mon, 14 Jun 2004 09:41:42 +1000
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 
> > > BTW, it looks like I missed the original IPv4 idev patch to route.c
> > > as well.  So could someone please tell me why it was needed in the
> > > first place?
> > 
> > Because per-device ipv4/ipv6 statistics support is coming.
> > It's necessary infrastructure.
> 
> Thanks.  Is there somewhere where I can look at the code that's
> going to use this infrastructure?

Not written yet, but it will be of the form:

	idev = rt->idev;
	SNMP_BUMP_BLAH_BLAH_STAT(idev);
