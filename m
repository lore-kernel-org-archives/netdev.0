From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 01/18] d80211:  LED triggers
Date: Fri, 22 Sep 2006 13:59:00 +0200
Message-ID: <20060922135900.13c72800@logostar.upir.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075158.728615077@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21638 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932320AbWIVL7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 07:59:03 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075158.728615077@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:08 +0200, Johannes Berg wrote:
> This patch makes d80211 export LED triggers for rx/tx and introduces
> functions to allow device drivers to query the trigger names for setting
> default triggers. It also cleans up the Makefile LED related stuff.

Applied to my tree with two changes (agreed by Johannes):

- added #include <linux/list.h> and <linux/spinlock.h> to workaround
  problems with leds.h
- added "select NEW_LEDS" to Kconfig

Thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
