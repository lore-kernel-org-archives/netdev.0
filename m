From: James Morris <jmorris@redhat.com>
Subject: Re: pskb change in dst->output
Date: Wed, 7 Jul 2004 21:05:11 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407072104170.29077-100000@thoron.boston.redhat.com>
References: <20040707171759.025eb13b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040707171759.025eb13b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004, David S. Miller wrote:

> That is what James's changes, to move the actual packet mucking deeper
> in the netfilter call chain (to where packet modifications really happen)
> so that we can fix the above described case without unneeded expense
> added.

Btw, this should also lead to a performance increase for Netfilter, 
although I haven't measured it.


- James
-- 
James Morris
<jmorris@redhat.com>
