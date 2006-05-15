From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against	802.11b
 drivers
Date: Mon, 15 May 2006 16:12:07 +0200
Message-ID: <20060515161207.13099472@griffin.suse.cz>
References: <200605042232.35446.flamingice@sourmilk.net>
	<1147694684.29795.30.camel@johannes.berg>
	<20060515153533.11491649@griffin.suse.cz>
	<200605151601.49290.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:48836 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964933AbWEOOMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 10:12:09 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200605151601.49290.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006 16:01:48 +0200, Michael Buesch wrote:
> No, We must allocate the ieee80211_hw, before we can attach the board.
> But before we attached the board, we don't know what hardware it is.
> Sure, this can be worked around by some very ugly hack (It was done
> in an early version of the dscape port, because there was no 
> ieee80211_update_hw), but I am not very happy to add the hack again.
> (I am not sure anymore _what_ we actually did to workaround it. I would
> have to look up the SVN repository ;) )

Isn't it possible to do attaching of the board between
ieee80211_alloc_hw and ieee80211_register_hw calls? You don't need to
call ieee80211_update_hw then.

Anyway, the ieee80211_update_hw function is here for a reason (solving
issues with a firmware primarily, but not exclusively), so use it if it
is easier for you.

 Jiri

-- 
Jiri Benc
SUSE Labs
