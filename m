From: James Morris <jmorris@redhat.com>
Subject: Re: af_packet & CHECKSUM_HW
Date: Sun, 16 Nov 2003 08:44:38 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com>
References: <20031115024434.GA12276@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031115024434.GA12276@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Nov 2003, Herbert Xu wrote:

> Hi:
> 
> Should the packet socket compute the checksums of CHECKSUM_HW packets
> before sending them to userspace?
> 
> In other words, what do I tell confused users who see bad checksums
> in the tcpdump output over loopback and interfaces capable of
> hardware checksums?

That this functionality does not belong in the kernel, as it serves no
real purpose.


- James
-- 
James Morris
<jmorris@redhat.com>
