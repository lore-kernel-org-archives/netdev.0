From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug#243084: net-tools: netstat do not display some ipv6
 listening sockets
Date: Sat, 1 May 2004 17:39:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501173925.4d88a826.davem@redhat.com>
References: <E1BCQ8h-0005bb-8s@thorr.asgardr.info>
	<20040411211116.GA32025@lina.inka.de>
	<87smfagpxf.fsf@thorr.asgardr.info>
	<20040412001011.GB3310@lina.inka.de>
	<20040412080013.GA24732@gondor.apana.org.au>
	<87fzb9z8zp.fsf@thorr.asgardr.info>
	<20040501065011.GA25540@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nebuchadnezzar@nerim.net, 243084@bugs.debian.org, be-mail2004@lina.inka.de,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040501065011.GA25540@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 1 May 2004 16:50:11 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> There is a bug in listening_get_first() which used by /proc/net/tcp*
> where it wasn't looping through all the sockets in each hash chain.
> This problem doesn't show up unless the first socket in a chain doesn't
> match the family that is being looked up.
> 
> The following patch fixes this by getting rid of listening_get_first()
> altogether.

Looks good, applied.

Thanks Herbert.
