From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Wed, 20 Feb 2013 11:17:34 -0800
Message-ID: <1361387854.19353.214.camel@edumazet-glaptop>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 (sfid-20130219_061917_530878_1ED7A14C) <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <1361290909.19353.140.camel@edumazet-glaptop>
	 (sfid-20130219_172155_748777_C3ED0F5E) <1361351538.8629.3.camel@jlt4.sipsolutions.net>
	 (sfid-20130220_101252_930264_DBD3955C) <1361351703.8629.5.camel@jlt4.sipsolutions.net>
	 <1361373064.19353.180.camel@edumazet-glaptop>
	 (sfid-20130220_161110_395796_DBAC0744) <1361377243.8629.34.camel@jlt4.sipsolutions.net>
	 <1361379331.19353.189.camel@edumazet-glaptop>
	 (sfid-20130220_175537_373410_F2F98F44) <1361379686.8629.41.camel@jlt4.sipsolutions.net>
	 <1361381096.19353.195.camel@edumazet-glaptop>
	 (sfid-20130220_182502_483935_369E6954) <1361384183.8579.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc@merlins.org>, David Miller <davem@davemloft.net>,
	Larry.Finger@lwfinger.net, bhutchings@solarflare.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:39719 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935757Ab3BTTRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 14:17:38 -0500
In-Reply-To: <1361384183.8579.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-20 at 19:16 +0100, Johannes Berg wrote:

> Yes and no. The current code doesn't pull in much data, not even the IP
> header, so worst case it copies 14 bytes (ethernet header) in mac80211
> to obtain alignment. By pulling in everything here, it later has to copy
> everything again later to obtain alignment.

Can you give me pointers to the code doing that ?

On x86 we should not doing anything.
