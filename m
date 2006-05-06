From: Uli Kunitz <kune@deine-taler.de>
Subject: Re: [RFC] Proposed structure for Regulatory/Geographical Wireless
 database
Date: Sat, 6 May 2006 07:07:20 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0605060702001.28448@p15091797.pureserver.info>
References: <445BB22B.30505@lwfinger.net> <Pine.LNX.4.58.0605052256570.26787@p15091797.pureserver.info>
 <445BC234.4060909@lwfinger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Uli Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org,
	Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Harald Welte <laforge@gnumonks.org>,
	Jouni Malinen <jkm@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:58044 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751146AbWEFFIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 01:08:06 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <445BC234.4060909@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger wrote:

> Uli Kunitz wrote:
> > Larry Finger wrote:
> > 
> > > * A new routine (ieee80211_init_geo ?) will be written to be called by the
> > > driver to load the geo structure into the kernel. Information passed to
> > > the
> > > daemon will be the country code in ASCII and whether the interface is to
> > > be
> > > used indoors or outdoors.
> > 
> > Would it be possible to support the regulatory domain codes as
> > used in the outdated table 105 in Corrigendum 1 for 802.11b? The
> > ZD1211 EEPROM contains only this code. An easy translation
> > function would be sufficient. Maybe the group codes could be
> > misused for it.
> 
> That certainly shouldn't be any difficulty. It could be done in the ZD1211
> driver before it calls the ieee80211_init_geo routine, or it could be done in
> the regulatory daemon. I assume that the EEPROM contains X'10' for FCC
> regulations, X'31' for Spain, etc.
> 
> Larry

Yes, it could be done in the driver. But if there are other
drivers having the same issue, the helper function should be
integrated in the geo code.

Uli

-- 
Uli Kunitz - kune@deine-taler.de
