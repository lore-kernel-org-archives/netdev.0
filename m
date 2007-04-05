From: Dave Jones <davej@redhat.com>
Subject: Re: [RFT] proxy arp deadlock possible
Date: Thu, 5 Apr 2007 00:49:47 -0400
Message-ID: <20070405044947.GB29736@redhat.com>
References: <E1HZG5h-0001oF-00@gondolin.me.apana.org.au> <1175735443.3270.11.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net, mingo@elte.hu, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161250AbXDEGSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 02:18:07 -0400
Content-Disposition: inline
In-Reply-To: <1175735443.3270.11.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 04, 2007 at 06:10:42PM -0700, Arjan van de Ven wrote:
 > On Thu, 2007-04-05 at 10:44 +1000, Herbert Xu wrote:
 > > Stephen Hemminger <shemminger@linux-foundation.org> wrote:
 > > > Thanks Dave, there is a classic AB BA deadlock here.
 > > > We should break the dependency like this.
 > > > 
 > > > Could someone who uses proxy ARP test this?
 > > 
 > > Sorry Stephen, this isn't necessary.  The lockdep thing is
 > > simply confused here.  It's treating tbl->proxy_queue as the
 > > same thing as neigh->arp_queue when they're clearly different.
 > > 
 > > I'm disappointed that after all this time lockdep is still
 > > producing bogus reports like this.  I'm sure we've been
 > > through this particular issue many times already.
 > 
 > 
 > what's the exact lockdep output here?

http://www.mail-archive.com/netdev@vger.kernel.org/msg35266.html

	Dave

-- 
http://www.codemonkey.org.uk
