From: James Morris <jmorris@redhat.com>
Subject: Re: pskb change in dst->output
Date: Fri, 9 Jul 2004 10:02:25 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407091001460.3887-100000@thoron.boston.redhat.com>
References: <20040709081443.GA11101@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040709081443.GA11101@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jul 2004, Herbert Xu wrote:

> On Thu, Jul 08, 2004 at 02:02:35PM +1000, herbert wrote:
> > 
> > That's only because the dst->output() functions are calling
> > skb_checksum_help().  Since those same functions assume the
> > skb to be "uncloned" anyway (they modify it directly by adding
> > headers etc.), they only need to call a version of
> > skb_checksum_help() that does not do a copy of the skb.
> 
> If there are no objections, I'd like to create a version of
> skb_checksum_help() that doesn't copy the packet, and call
> that version from ah_output()/esp_output()/ipcomp_output().

This will break when cloned packets are passed to these functions.


- James
-- 
James Morris
<jmorris@redhat.com>
