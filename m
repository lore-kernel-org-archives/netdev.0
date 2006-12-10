From: Pavel Roskin <proski@gnu.org>
Subject: Re: Please make CONFIG_CFG80211 harder to enable
Date: Sun, 10 Dec 2006 11:08:02 -0500
Message-ID: <20061210110802.kq50mvc4s00s0skw@webmail.spamcop.net>
References: <1165654123.2816.29.camel@portland.localdomain>
	<20061209160640.GA3365@tuxdriver.com>
	<87hcw49rg8.fsf@briny.internal.ondioline.org>
	<20061210031202.6rgqw4go8ck48kks@webmail.spamcop.net>
	<1165756653.3131.1.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Collins <paul@briny.ondioline.org>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.cesmail.net ([216.154.195.36]:60666 "HELO
	mailgate.cesmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1761779AbWLJQIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 11:08:04 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1165756653.3131.1.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Johannes Berg <johannes@sipsolutions.net>:

> On Sun, 2006-12-10 at 03:12 -0500, Pavel Roskin wrote:
>
> > Yes.  And I could trace "iwgetid -m ath0" to cfg80211_wx_get_mode() in
> > net/wireless/wext-compat.c, which returns -ENOSYS unconditionally.  ath0 is
> > from current MadWifi.
>
> Now trace it further and notice that on -ENOSYS the original WE is
> invoked.

Not quite.  cfg80211_wext_ioctl() returns -ENODEV (no idea why), but the code
only falls back to Wireless Extensions if the return code is -ENOSYS.  That
should be quite easy to fix.

--
Regards,
Pavel Roskin
