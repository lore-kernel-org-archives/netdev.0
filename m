From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 23:05:00 +0200
Message-ID: <20060421230500.1fd6be92@griffin.suse.cz>
References: <20060421201147.D4F76482CF@silver.suse.cz>
	<1145651369.3897.33.camel@localhost>
	<20060421224935.5acd79bf@griffin.suse.cz>
	<1145652778.3897.43.camel@localhost>
	<20060421225729.34dae18b@griffin.suse.cz>
	<1145653288.3897.49.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:37288 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964773AbWDUVFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 17:05:02 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145653288.3897.49.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Apr 2006 23:01:28 +0200, Johannes Berg wrote:
> Yes, but didn't you just say that when monitor_during_oper == 0 then
> it's equivalent to promisc mode?

Not necessary. It was just an example of the worst case. In typical
case, you will receive something more - probably all data and management
frames but no control frames.

 Jiri

-- 
Jiri Benc
SUSE Labs
