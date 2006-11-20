From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] d80211: remove useless driver name field
Date: Mon, 20 Nov 2006 22:21:47 +0000
Message-ID: <20061120222147.GA7148@infradead.org>
References: <1163802439.3392.47.camel@johannes.berg> <1163803835.3392.52.camel@johannes.berg> <20061120183213.GB5983@instant802.com> <1164048000.9216.29.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58019 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S966386AbWKTWWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 17:22:11 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1164048000.9216.29.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 20, 2006 at 07:40:00PM +0100, Johannes Berg wrote:
> On Mon, 2006-11-20 at 10:32 -0800, Jouni Malinen wrote:
> > On Fri, Nov 17, 2006 at 11:50:35PM +0100, Johannes Berg wrote:
> > 
> > > struct ieee80211_ops has a driver name field that's never used.
> > > Remove it.
> > 
> > >  struct ieee80211_ops {
> > > -	/* Driver name */
> > > -	char *name;
> > > -
> > 
> > Is this the same name field that was in struct ieee80211_hw?
> 
> Yes, it moved here during the shuffle in patch 6.
> 
> > It was used
> > and the main reason was to allow rate control algorithms to be
> > implemented in a way which allows hardware specific features (e.g.,
> > different TX/RX status data) to be used to optimize rate selection. I
> > would not remove this field unless there is another way of allowing
> > something like this to be done in the rate control modules.
> 
> Oh, I hadn't found any references to it but I guess those rate control
> modules are internal. I'm fine with leaving it in.

NACK.  We don't leave unused junk in tree.  Especially not to allow
implementing layering violations in non-public code.
