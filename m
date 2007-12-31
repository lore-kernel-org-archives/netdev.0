From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH net-2.6.25 4/7][ATM]: [br2864] routed support
Date: Mon, 31 Dec 2007 10:44:46 -0500
Message-ID: <200712311544.lBVFikVL012169@cmf.nrl.navy.mil>
References: <20071231090957.GA28855@infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:60125 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbXLaPpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 10:45:18 -0500
In-reply-to: <20071231090957.GA28855@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20071231090957.GA28855@infradead.org>,Christoph Hellwig writes:
>> +#define LLC		0xaa, 0xaa, 0x03
>> +#define SNAP_BRIDGED	0x00, 0x80, 0xc2
>> +#define SNAP_ROUTED	0x00, 0x00, 0x00
>> +#define PID_ETHERNET	0x00, 0x07
>> +#define ETHERTYPE_IPV4	0x08, 0x00
>> +#define ETHERTYPE_IPV6	0x86, 0xdd
>> +#define PAD_BRIDGED	0x00, 0x00
...
>> +	{ LLC, SNAP_BRIDGED, PID_ETHERNET, PAD_BRIDGED };
>> +static unsigned char llc_oui_ipv4[] =
>> +	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
>> +static unsigned char llc_oui_ipv6[] =
>> +	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };
>
>I think this should be in a global header.  And IIRC we already have
>at least some of these somewhere as part of the general llc support.

sounds good to me, but i dont think its already in a generalized
llc header.  the only appearance i can find is:

net/ieee80211/ieee80211_rx.c:static unsigned char rfc1042_header[] = { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
net/ieee80211/ieee80211_rx.c:    { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };
net/ieee80211/ieee80211_tx.c:      | 0xAA | 0xAA |0x03 (UI)|0x00-00-F8|      |         |
net/mac80211/util.c:    { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
net/mac80211/util.c:    { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };

any suggestions on how and where you would like to see these structures?
