From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/13] d80211: clean up some stupid list and loop code
Date: Mon, 20 Nov 2006 12:58:10 +0100
Message-ID: <1164023890.2744.28.camel@ux156>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964140.15473.39.camel@johannes.berg>
	 <20061120120133.75182913@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37849 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S934077AbWKTL5D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 06:57:03 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061120120133.75182913@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-20 at 12:01 +0100, Jiri Benc wrote:

> > +	list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {
> 
> There is no need for _safe here.

Ok, wasn't sure about that one so I left it safe (it was before I
think). I'll remove it when I respin.

johannes
