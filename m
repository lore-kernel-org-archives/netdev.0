From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net-next PATCH RFC 0/3] Preserve skb->mark through VTI tunnels
Date: Wed, 27 May 2015 09:48:40 +0200
Message-ID: <20150527074836.GA27342@secunet.com>
References: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, <linux-crypto@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2015 at 03:41:10PM -0700, Alexander Duyck wrote:
> These patches are meant to try and address the fact the VTI tunnels are
> currently overwriting the skb->mark value.  I am generally happy with the
> first two patches, however the third patch still modifies the skb->mark,
> though it undoes after the fact.

I don't see any better solution, so I think this should be ok for now.
On the long run we need to replace this gre key/mark matching with
a separate interface.

> 
> The main problem I am trying to address is the fact that currently if I use
> an v6 over v6 VTI tunnel I cannot receive any traffic on the interface as
> the skb->mark is bleeding through and causing the traffic to be dropped.

This is broken in the current mainline, so it should go into the ipsec
tree as a bugfix. I'd merge this patchset if you submit it to that tree.

Thanks!
