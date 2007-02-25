From: Al Boldi <a1426z@gawab.com>
Subject: Re: ipv4 and ipv6 stacks for new link layers?
Date: Sun, 25 Feb 2007 14:21:16 +0300
Message-ID: <200702251421.16863.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964788AbXBYLSc@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Markku Savela <msa@moth.iki.fi>
> > I think that is worse than allow a new driver to provide a simple
> > service function which maps IPv4/6 multicast address into link layer
> > address, when asked.
>
> The problem is that this mapping isn't so simple for several
> link layer types.

But this mapping seems to be just a simple de-coupling tool, and any 
de-coupling by definition does/should not change the underlying 
implementation in any way, while allowing for a dynamic rather than a 
fixed/hardcoded relation between the layers.

So, can you give an example of a link-layer that does not easily de-couple 
from the transport?


Thanks!

--
Al
