From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless-2.6 zd1211rw check against regulatory domain
	rather than hardcoded value of 11
Date: Mon, 30 Oct 2006 09:42:29 +0100
Message-ID: <1162197749.2854.5.camel@ux156>
References: <f46018bb0610231121s4fb48f88l28a6e7d4f31d40bb@mail.gmail.com>
	 <453D48E5.8040100@gentoo.org>
	 <f46018bb0610240709y203d8cdbw95cdf66db23aa1ce@mail.gmail.com>
	 <453E2C9A.7010604@gentoo.org>  <4544CBC8.5090305@deine-taler.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Holden Karau <holden@pigscanfly.ca>,
	zd1211-devs@lists.sourceforge.net, linville@tuxdriver.com,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	holdenk@xandros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:5298 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751381AbWJ3Ill
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 03:41:41 -0500
To: Uli Kunitz <kune@deine-taler.de>
In-Reply-To: <4544CBC8.5090305@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'm not so sure about this. This patching might be US-specific and we 
> cannot simply apply the setting for top channel of another domain 
> instead of channel 11. One option would be to set the value only under 
> the US regulatory domain.

??
What the patch does is replace the top channel which is hardcoded to 11
by the top channel given by the current regulatory domain. How can that
be wrong? Except that you may want to init the regulatory domain from
the EEPROM but I'm not sure how the ieee80211 code works wrt. that.

johannes
