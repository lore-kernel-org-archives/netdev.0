From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: d80211: clean up some list and loop code
Date: Thu, 16 Nov 2006 15:40:34 -0800
Message-ID: <20061116234034.GA6127@instant802.com>
References: <1163718270.3392.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-82.dex002.intermedia.net ([64.78.20.215]:46882 "EHLO
	dhost002-82.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1424570AbWKPXkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 18:40:42 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163718270.3392.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 17, 2006 at 12:04:29AM +0100, Johannes Berg wrote:
> Remove things like "for (;;)" or "for (; condition ;)".
> Ever heard of while loops?

Isn't "for (;;)" the standard way of doing infinite loops? Please don't
change that. Changing loops to use list_for_each*() is of course
welcome.

-- 
Jouni Malinen                                            PGP id EFC895FA
