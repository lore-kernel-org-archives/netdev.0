From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] kfree_skb() bug in 2.4.22
Date: Wed, 8 Oct 2003 06:47:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008064735.7373227b.davem@redhat.com>
References: <1065617075.1514.29.camel@localhost>
	<3F840C9C.9050704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: toby@cbcg.net, netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org, coreteam@netfilter.org,
        netfilter@lists.netfilter.org, akpm@zip.com.au, kuznet@ms2.inr.ac.ru,
        pekkas@netcore.fi, jmorris@intercode.com.au, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F840C9C.9050704@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 08 Oct 2003 09:09:48 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> I would prefer that you fix your code instead, to not pass NULL to 
> kfree_skb()...

Absolutely, there is no valid reason to pass NULL into these
routines.
