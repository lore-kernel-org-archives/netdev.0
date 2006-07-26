From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style
 names
Date: Wed, 26 Jul 2006 18:32:00 +0200
Message-ID: <20060726183200.79fb431e@griffin.suse.cz>
References: <200607242302.58670.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14721 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750910AbWGZQcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 12:32:03 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607242302.58670.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Jul 2006 23:02:50 -0700, Michael Wu wrote:
> These two attached patches also roll in a switch to MAC_FMT and MAC_ARG, and 
> use IEEE80211_DATA_LEN when possible. Otherwise, it's the same as before 
> except split into two patches.

Nice, thanks a lot.

One more thing (hopefully the last one), could you try to keep lines
under 80 characters? I understand that with such long identifiers it is
not always possible (it dramatically reduces readability of the code if
you try to force the limit in every case) but there are some places
where it is feasible.

Also, when changing a line that is indented with spaces instead of tab
characters, it's nice to convert that spaces to tabs. That's not a
requirement, though; I will modify the patch if you won't do it.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
