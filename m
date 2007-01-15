From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] Remove CONFIG_NET_WIRELESS
Date: Mon, 15 Jan 2007 15:40:08 +0100
Message-ID: <20070115154008.0dedf451@griffin.suse.cz>
References: <45A91414.40107@gmail.com>
	<1168860268.3344.0.camel@johannes.berg>
	<45AB79D1.2070002@gmail.com>
	<1168867866.3344.3.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Maarten Lankhorst <m.b.lankhorst@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40014 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750728AbXAOOkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 09:40:10 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1168867866.3344.3.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jan 2007 13:31:06 +0000, Johannes Berg wrote:
> On Mon, 2007-01-15 at 13:55 +0100, Maarten Lankhorst wrote:
> > Enabling this doesn't cause anything to fail, but my wireless router
> > doesn't have a pci bus, but instead a native SSB, so CONFIG_NET_WIRELESS
> > isn't selected. This in turn causes wext-common.o to not be built, so I
> > get missing symbols and a build breakage. That's why I made
> > wext-common.o depend on CONFIG_WIRELESS_EXT instead of
> > CONFIG_NET_WIRELESS. Since nothing else uses CONFIG_NET_WIRELESS I
> > decided to kill that symbol.
> 
> Ok, that makes sense to me. Let's put this in but with this better
> description rather than the original one.

The original mail with patch apparently didn't get to netdev (I haven't
received it and it's not in netdev archive). Maarten, could you resend
it please?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
