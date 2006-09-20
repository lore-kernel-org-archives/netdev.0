From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC 3/3] cfg80211 thoughts on configuration
Date: Wed, 20 Sep 2006 09:07:34 +0200
Message-ID: <20060920070734.GJ18349@postel.suug.ch>
References: <1158230812.2936.46.camel@ux156> <1158231183.2936.55.camel@ux156> <20060920063306.GH18349@postel.suug.ch> <1158735787.2665.2.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45756 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751254AbWITHHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 03:07:14 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1158735787.2665.2.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-09-20 09:03
> > Just use a nested attribute here, this new array format you introduce
> > having 1 byte ID, 1 byte len is equivalent to using a set of nested
> > attributes with nla_type=id, nla_len=len.
> 
> No, it is only validated, it is then supposed to be copied verbatim into
> some 802.11 frames. I thought validating it would be a good idea to not
> send out totally bogus frames, but I didn't want to have to mangle it in
> the kernel.

I see, fair enough, wasn't able to get that from your code.
