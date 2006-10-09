From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: cfg80211 take 7
Date: Mon, 9 Oct 2006 11:38:54 -0700
Message-ID: <20061009183854.GA6676@devicescape.com>
References: <1160146790.2715.82.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:15797 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751890AbWJISjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 14:39:09 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1160146790.2715.82.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


FYI, all three patches mentioned as possibly required by the nl80211
patchset in the header of nl80211.patch are already in wireless-dev:

http://marc.theaimsgroup.com/?l=linux-netdev&m=115625436628696&w=2
(Introduces NLA_NUL_STRING) 

http://marc.theaimsgroup.com/?l=linux-netdev&m=115625168405439&w=2
(Convert existing NLA_STRING attributes to use the new validation
features)

http://marc.theaimsgroup.com/?l=linux-netdev&m=115650333420169&w=2
(remove value argument from NLA_PUT_FLAG)

I also updated the patchset a bit to apply to current wireless-dev.
I will send that to Johannes directly.



On Fri, Oct 06, 2006 at 04:59:50PM +0200, Johannes Berg wrote:
> Hah, take 6 was eaten by netdev (even the announcement) but it did reach
> some people (and before those who did get it wonder: I resent to netdev,
> the original mail was accidentally not addressed to netdev, so it's not
> that I simply didn't send it).
> 
> anyway, it's getting large, so... straight from quilt:
> http://johannes.sipsolutions.net/files/cfg80211/
> 
> order is:
> nl80211.patch
> move-wext.patch
> wext-compat.patch
> 
> johannes
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
