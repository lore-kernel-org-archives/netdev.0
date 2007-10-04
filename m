From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted
	to managed
Date: Thu, 4 Oct 2007 14:07:41 -0400
Message-ID: <20071004180741.GF6037@tuxdriver.com>
References: <20071004113343.552139D502B@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3567 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758811AbXJDSi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 14:38:29 -0400
Content-Disposition: inline
In-Reply-To: <20071004113343.552139D502B@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2007 at 12:33:43PM +0100, Daniel Drake wrote:

> Fix this by unsetting the hard_start_xmit handler in ieee80211_if_reinit. It
> will then be reinitialised to the default (ieee80211_subif_start_xmit) in
> ieee80211_if_set_type.

I think I'd rather fix this by making the check in
ieee80211_if_set_type more explicit for master devices.  Patch to
follow.

John
-- 
John W. Linville
linville@tuxdriver.com
