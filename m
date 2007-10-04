From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted to managed
Date: Thu, 4 Oct 2007 17:06:05 +0200
Message-ID: <200710041706.06182.mb@bu3sch.de>
References: <20071004113343.552139D502B@zog.reactivated.net> <200710041034.48533.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, linville@tuxdriver.com,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:38593
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756667AbXJDPGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 11:06:41 -0400
In-Reply-To: <200710041034.48533.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 04 October 2007 16:34:43 Michael Wu wrote:
> On Thursday 04 October 2007 07:33, Daniel Drake wrote:
> > Fix this by unsetting the hard_start_xmit handler in ieee80211_if_reinit.
> > It will then be reinitialised to the default (ieee80211_subif_start_xmit)
> > in ieee80211_if_set_type.
> >
> Well.. this kinda sucks, but we can clean up the logic here later.
> 
> > +	BUG_ON(netif_running(dev));
> This will never happen, so there's no point.

The reason why BUG_ON exists is to catch bugs that happen, although
they Should Never Happen (tm) ;)

-- 
Greetings Michael.
