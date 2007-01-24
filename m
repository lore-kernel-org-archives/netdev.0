From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 24 Jan 2007 15:13:34 -0500
Message-ID: <20070124201334.GB5806@tuxdriver.com>
References: <20070117141103.0e468bf4@griffin.suse.cz> <1169046072.2750.10.camel@localhost.localdomain> <1169047134.9175.49.camel@johannes.berg> <1169055788.2550.44.camel@localhost.localdomain> <1169056847.2550.56.camel@localhost.localdomain> <20070117230945.GB9387@infradead.org> <45AEAEEB.6050603@pobox.com> <20070118082250.GE11056@tuxdriver.com> <20070124152638.GC3036@dmt.poa.virtua.com.br> <1169664755.14073.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Christoph Hellwig <hch@infradead.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3101 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932617AbXAXUkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 15:40:47 -0500
Content-Disposition: inline
In-Reply-To: <1169664755.14073.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 24, 2007 at 01:52:35PM -0500, Dan Williams wrote:

> I pushed for a general "lib80211" sort of thing at the Summit, which I
> think was agreed in principle with others like Intel.  We need something
> to hold the bits that are common to d80211 and non-softmac drivers.
> These include scan result handling, some bits of the regulatory stuff
> (at least structures and definitions for allowed channels and txpower in
> each domain), and 802.3 <-> 802.11 framing conversion code.  We should
> be able to fold more stuff in there as we go along.  But there certainly
> will be code that both softmac/d80211 and non-softmac drivers (airo,
> ipw2x00, libertas, etc) can share.

ACK

-- 
John W. Linville
linville@tuxdriver.com
