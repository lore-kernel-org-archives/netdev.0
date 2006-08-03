From: Christoph Hellwig <hch@infradead.org>
Subject: Re: orinoco driver causes *lots* of lockdep spew
Date: Thu, 3 Aug 2006 15:11:53 +0100
Message-ID: <20060803141153.GB20405@infradead.org>
References: <1154607380.2965.25.camel@laptopd505.fenrus.org> <E1G8der-0001fm-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, davej@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, linville@tuxdriver.com, jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:24032 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932485AbWHCOME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 10:12:04 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G8der-0001fm-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 11:54:41PM +1000, Herbert Xu wrote:
> Arjan van de Ven <arjan@infradead.org> wrote:
> > 
> > this is another one of those nasty buggers;
> 
> Good catch.  It's really time that we fix this properly rather than
> adding more kludges to the core code.
> 
> Dave, once this goes in you can revert the previous netlink workaround
> that added the _bh suffix.
> 
> [WIRELESS]: Send wireless netlink events with a clean slate

Could we please just get rid of the wireless extensions over netlink code
again?  It doesn't help to solve anything and just creates a bigger mess
to untangle when switching to a fully fledged wireless stack.

