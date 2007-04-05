From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFT] proxy arp deadlock possible
Date: Wed, 04 Apr 2007 18:10:42 -0700
Message-ID: <1175735443.3270.11.camel@laptopd505.fenrus.org>
References: <E1HZG5h-0001oF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net, mingo@elte.hu, davej@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58840 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbXDEBLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 21:11:22 -0400
In-Reply-To: <E1HZG5h-0001oF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-04-05 at 10:44 +1000, Herbert Xu wrote:
> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > Thanks Dave, there is a classic AB BA deadlock here.
> > We should break the dependency like this.
> > 
> > Could someone who uses proxy ARP test this?
> 
> Sorry Stephen, this isn't necessary.  The lockdep thing is
> simply confused here.  It's treating tbl->proxy_queue as the
> same thing as neigh->arp_queue when they're clearly different.
> 
> I'm disappointed that after all this time lockdep is still
> producing bogus reports like this.  I'm sure we've been
> through this particular issue many times already.


what's the exact lockdep output here?

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

