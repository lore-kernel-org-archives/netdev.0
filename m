From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]Fix adding SA through netlink(xfrm_user)
Date: Wed, 28 Jul 2004 19:07:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728190728.2dcf06f7.davem@redhat.com>
References: <20040729001058.48cd1791@localhost>
	<Xine.LNX.4.44.0407281134500.11200-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0407281134500.11200-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jul 2004 11:41:33 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> On Thu, 29 Jul 2004, Masahide Nakamura wrote:
> 
> > When adding IPsec SA with PF_KEY (pfkey_add()),
> > xfrm_probe_algs() is called to make all algorithms valid.
> > However, it is missing to call it with netlink (xfrm_user) case and
> > it causes xfrm_aalg_get_byname() return NULL even if the name of
> > algorithm seems to be correct.
> 
> Looks ok, but odd that this has not been picked up before.

As discovered, this never got picked up before mostly
because the most popular user of xfrm_user (Openswan)
is still using PF_KEY to probe the algorithms.

Patch applied, arigato Masahide-san.
