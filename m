From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: clean up those huge else if statements; use
 BUILD_BUG_ON
Date: Thu, 21 Sep 2006 21:25:18 +0200
Message-ID: <20060921212518.667a0cbd@logostar.upir.cz>
References: <1156927261.4013.53.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57778 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751473AbWIUTZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:25:21 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156927261.4013.53.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 10:41:00 +0200, Johannes Berg wrote:
> This patch replaces the if (...) else if (...) else if (...) ...
> statements I complained about earlier with switches.

On Wed, 30 Aug 2006 10:39:30 +0200, Johannes Berg wrote:
> This patch makes d80211 use BUILD_BUG_ON instead of checking at module
> initialisation time. This check really is only interesting while you
> hack since if the module was built, then it's either an 'always true' or
> 'always false' comparison, hence useless to do it at runtime.

Both patches applied to my tree. Thanks!

 Jiri

-- 
Jiri Benc
SUSE Labs
