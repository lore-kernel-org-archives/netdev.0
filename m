From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 4/10] d80211: reduce mdev usage, fix ieee80211_rx_mgmt
Date: Mon, 20 Nov 2006 18:44:38 +0100
Message-ID: <20061120184438.5fabfb43@griffin.suse.cz>
References: <20061119163545.GA25557@devicescape.com>
	<1163954276.15473.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:61840 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S966281AbWKTRok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 12:44:40 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163954276.15473.21.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 19 Nov 2006 17:37:56 +0100, Johannes Berg wrote:
> I'm thinking there might be race conditions where userspace does
> something, then drops the ap device but after that some operations
> complete and would lead to the oops too. Wasn't really sure.

Yes, that's possible. But your check doesn't solve it.

Anyway, it's not worse than today, so ACK.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
