From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: 2.6.7: sk98lin unload oops
Date: Mon, 5 Jul 2004 00:01:35 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200407050001.46489.bernd-schubert@web.de>
References: <200407041342.18821.bernd-schubert@web.de> <200407042028.59047.bernd-schubert@web.de> <20040704184404.GA7262@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265805AbUGDWBn@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <20040704184404.GA7262@infradead.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


> Sorry, it's for Linus' current BK tree.  I've attached three files that
> you should be able to just copy over your regular 2.6.7 tree:

Thanks, this driver compiles fine.


[from your other mail]
> the previous one) makes it work unless you change the interface name
> manually, but as Linux explicitly allows that the interface is
> fundamentally broken and probably should just go away.

Unfortunality we rename all interfaces using ifrename to make sure that the 
interface names won't change with different kernel versions (we have this 
problem when we switch between 2.4. and 2.6.). So it is normal that the oops 
occurs on unloading the modules?


Btw, on 22th June I got another skge.c patch from Herbert Xu to fix another 
oops:

http://lkml.org/lkml/2004/6/22/44

This patch applies fine on top of your new versions (with 400 lines offset), 
maybe this patch should also be included into the current BK tree?

Thanks a lot,
	Bernd
