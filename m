From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] add nl80211
Date: Fri, 25 Aug 2006 12:30:41 +0200
Message-ID: <20060825103041.GQ3470@postel.suug.ch>
References: <1156254768.3825.1.camel@ux156> <1156435624.10283.9.camel@ux156> <20060824172717.GN3470@postel.suug.ch> <1156496671.3893.6.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:18892 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932400AbWHYKaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 06:30:20 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156496671.3893.6.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-08-25 11:04
> I completely reworked that now so it will:
>  * create a nested NL80211_ATTR_INTERFACE_LIST with nested {
>    * 1..N attributes, with nested {
>      * ATTR_IFINDEX and
>      * ATTR_IFNAME
>    }
>  }
> 
> how does that sound? Maybe I should do the same for the WIPHY list? i.e.
> create a new type ATTR_WIPHY_LIST and within that nest numbered
> attributes (array indexes) and in there put ATTR_WIPHY? So possibly I
> could also put ATTR_INTERFACE_LIST in there as well later?

That's exactly what I would have done as well.
