From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: wireless userspace MLME and generic netlink vs. multicast
	(was: Re: [Take 2] mac80211 IEEE802.11e/WMM code cleanup)
Date: Mon, 18 Jun 2007 10:08:47 +0800
Message-ID: <1182132527.4092.90.camel@debian.sh.intel.com>
References: <20070611085950.GA5540@mail.intel.com>
	 <200706161129.13782.flamingice@sourmilk.net>
	 <1182019869.9058.57.camel@johannes.berg>
	 <200706161516.16447.flamingice@sourmilk.net>
	 <1182081831.23681.29.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	David Lamparter <lists@diac24.net>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46813 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584AbXFRCKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2007 22:10:39 -0400
In-Reply-To: <1182081831.23681.29.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-06-17 at 14:03 +0200, Johannes Berg wrote:
> It sounds to me like you're proposing that wpa_supplicant is the only
> supported userspace MLME and that wpa_cli is the only way to configure
> it, basically. I sure hope that isn't so. 

OK. This is the key of the discussion. Do we take wpa_supplicant the
only implementation of userspace MLME or even decision making (ie. DLS
config) daemon? If so, we don't need the API. Otherwise we'd better have
the API in the kernel because we cannot expect both userspace MLME
implentation A and B support the same API (via IPC) for configuration.

Thanks,
-yi
