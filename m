From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Fix __ieee80211_if_del on live interfaces
Date: Wed, 10 Jan 2007 21:16:09 +0100
Message-ID: <20070110211609.78d65423@griffin.suse.cz>
References: <200701100119.19523.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>,
	Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36384 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965083AbXAJUQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:16:10 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200701100119.19523.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Jan 2007 01:19:14 -0500, Michael Wu wrote:
> This patch fixes that by setting dev->uninit to ieee80211_if_reinit and
> eliminating the call to ieee80211_if_reinit in __ieee80211_if_del. This
> allows ieee80211_if_reinit to be called at a safer time. It also allows
> the removal of the call to ieee80211_if_shutdown in ieee80211_if_reinit
> because ieee80211_if_reinit now will never be called while the interface
> is up.

Applied to my tree, thanks for the patch. (And I can confirm it fixes
the problem reported by Michael Buesch too.)

 Jiri

-- 
Jiri Benc
SUSE Labs
