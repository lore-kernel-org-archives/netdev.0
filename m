From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Thu, 21 Apr 2005 20:13:31 -0700
Message-ID: <20050421201331.349f214b.davem@davemloft.net>
References: <20050328233917.GB15369@gondor.apana.org.au>
	<424B40C2.90304@trash.net>
	<20050331004658.GA26395@gondor.apana.org.au>
	<20050331212325.5e996432.davem@davemloft.net>
	<20050402004956.GA24339@gondor.apana.org.au>
	<20050401172007.7296eced.davem@davemloft.net>
	<20050402020947.GA24998@gondor.apana.org.au>
	<42501E51.3000401@trash.net>
	<20050405103918.GA24863@gondor.apana.org.au>
	<4252EEA2.5020107@trash.net>
	<20050406022155.GA12952@gondor.apana.org.au>
	<20050421163526.7a29a76f.davem@davemloft.net>
	<42683D07.6090808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42683D07.6090808@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 01:53:43 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Yes, tmpl->id.daddr might be 0, in which case the destination
> of the packet or previous tunnel mode transforms is used. daddr
> always contains the correct adress, so we should use it to check
> for duplicate SPIs. But as Herbert noted, we shouldn't perform
> the check if tmpl->id.spi == 0, so here is a new patch.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Ok, that makes sense.  Patch applied, thanks guys.
