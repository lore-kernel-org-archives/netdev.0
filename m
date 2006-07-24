From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Make MACSTR/MAC2STR macro
 available to drivers
Date: Mon, 24 Jul 2006 15:54:35 +0200
Message-ID: <20060724155435.6ec32485@griffin.suse.cz>
References: <200607230143.31375.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21202 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932164AbWGXNyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 09:54:37 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607230143.31375.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 23 Jul 2006 01:43:25 -0700, Michael Wu wrote:
> This patch moves the MACSTR/MAC2STR macros to d80211.h
> so that they are available to drivers. It also converts the adm8211
> and bcm43xx drivers to use this macro.

I really dislike those MACSTR/MAC2STR names. I always fail to remember
which one is which. What about renaming them when we are touching them?

And why not to use MAC_FMT/MAC_ARG names as used in net/ieee80211.h? ;-)

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
