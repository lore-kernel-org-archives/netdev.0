From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: af_packet & CHECKSUM_HW
Date: Mon, 17 Nov 2003 20:44:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117194452.GB18448@vana.vc.cvut.cz>
References: <20031115024434.GA12276@gondor.apana.org.au> <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com> <20031116205146.GA8477@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20031116205146.GA8477@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2003 at 07:51:46AM +1100, Herbert Xu wrote:
> On Sun, Nov 16, 2003 at 08:44:38AM -0500, James Morris wrote:
> > On Sat, 15 Nov 2003, Herbert Xu wrote:
> >
> > > In other words, what do I tell confused users who see bad checksums
> > > in the tcpdump output over loopback and interfaces capable of
> > > hardware checksums?
> > 
> > That this functionality does not belong in the kernel, as it serves no
> > real purpose.
> 
> OK, I will quote you on that :)

It would be nice if at least kernel did not stomp on skb2->h.raw so
ptype callback could cope with situation and report to userspace where
to put checksum. I already discussed it here two or so months ago, and
only solution I was able to find is that VMware's vmnet have to parse
itself network headers to find where to put checksum. Nothing for IPv6
users...
						Best regards,
							Petr Vandrovec
