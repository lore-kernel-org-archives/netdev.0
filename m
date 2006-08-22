From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 08/18] d80211:  clean up exports
Date: Tue, 22 Aug 2006 09:44:36 -0700
Message-ID: <20060822164436.GG13240@instant802.com>
References: <20060821074107.648561364@sipsolutions.net> <20060821075200.277082970@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-38.dex002.intermedia.net ([64.78.21.123]:49975 "EHLO
	dhost002-38.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751415AbWHVQos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 12:44:48 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <20060821075200.277082970@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 09:41:15AM +0200, Johannes Berg wrote:
> This puts all EXPORT_SYMBOL() macros along with the function being exported,
> and changes some exports that are only relevant to rate control modules
> and to be GPL-only because they rate control modules need to be built against
> the internal ieee80211_i.h header.

Moving the EXPORT_SYMBOL definitions sounds good, but I would like to
keep changes between EXPORT_SYMBOL and EXPORT_SYMBOL_GPL separate from
this kind of cleanup. In addition, I'm not personally a huge fan of the
EXPORT_SYMBOL_GPL in the first place since I believe the GPL should
cover this without additional changes in the source code. In other
words, I would prefer that the EXPORT_SYMBOL would not be changed to
EXPORT_SYMBOL_GPL here.

-- 
Jouni Malinen                                            PGP id EFC895FA
