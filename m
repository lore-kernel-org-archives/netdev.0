From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 3/3] cfg80211 thoughts on configuration
Date: Wed, 20 Sep 2006 09:03:07 +0200
Message-ID: <1158735787.2665.2.camel@ux156>
References: <1158230812.2936.46.camel@ux156>
	 <1158231183.2936.55.camel@ux156>  <20060920063306.GH18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:11719 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751004AbWITHC2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 03:02:28 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060920063306.GH18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-20 at 08:33 +0200, Thomas Graf wrote:

> I think I brought this up already, it's a lot easier to understand
> things if you keep it symmetric, i.e. NL80211_CMD_GET_CONFIG triggers
> sending a NL80211_CMD_NEW_CONFIG.

Yes, I think you did :) I'll do that as soon as I get around to
reworking it (hoping for more comments...)

> Just use a nested attribute here, this new array format you introduce
> having 1 byte ID, 1 byte len is equivalent to using a set of nested
> attributes with nla_type=id, nla_len=len.

No, it is only validated, it is then supposed to be copied verbatim into
some 802.11 frames. I thought validating it would be a good idea to not
send out totally bogus frames, but I didn't want to have to mangle it in
the kernel.

johannes
