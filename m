From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] d80211: remove useless driver name field
Date: Mon, 20 Nov 2006 10:32:13 -0800
Message-ID: <20061120183213.GB5983@instant802.com>
References: <1163802439.3392.47.camel@johannes.berg> <1163803835.3392.52.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-79.dex002.intermedia.net ([64.78.20.164]:11489 "EHLO
	DHOST002-79.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S966365AbWKTScY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 13:32:24 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163803835.3392.52.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 17, 2006 at 11:50:35PM +0100, Johannes Berg wrote:

> struct ieee80211_ops has a driver name field that's never used.
> Remove it.

>  struct ieee80211_ops {
> -	/* Driver name */
> -	char *name;
> -

Is this the same name field that was in struct ieee80211_hw? It was used
and the main reason was to allow rate control algorithms to be
implemented in a way which allows hardware specific features (e.g.,
different TX/RX status data) to be used to optimize rate selection. I
would not remove this field unless there is another way of allowing
something like this to be done in the rate control modules.

-- 
Jouni Malinen                                            PGP id EFC895FA
