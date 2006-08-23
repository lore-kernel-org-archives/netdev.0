From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 16/18] d80211:  get rid of MICHAEL_MIC_HWACCEL define
Date: Wed, 23 Aug 2006 11:46:47 +0200
Message-ID: <20060823114647.763a8f89@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075202.538664376@sipsolutions.net>
	<20060822210038.53ee194c@griffin.suse.cz>
	<1156316730.3629.7.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44006 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751506AbWHWJqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 05:46:49 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156316730.3629.7.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006 09:05:30 +0200, Johannes Berg wrote:
> On Tue, 2006-08-22 at 21:00 +0200, Jiri Benc wrote:
> > When you're touching this, could you #ifdef out wpa_test when
> > CONFIG_HOSTAPD_WPA_TESTING is not defined? This could be a part of this
> > patch.
> 
> I thought about it but deemed it too ugly. And wouldn't the compiler
> optimize it away anyway? Thing is, it's used in tests, and having
> #ifdefs within if (...) tests is hugely ugly.

#ifdefs within if tests are ugly, I agree. I thought about restructuring
these ifs. Okay, we will go with your patch and address this later.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
