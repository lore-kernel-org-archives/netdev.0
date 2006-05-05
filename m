From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC] Proposed structure for Regulatory/Geographical Wireless
 database
Date: Fri, 05 May 2006 16:23:00 -0500
Message-ID: <445BC234.4060909@lwfinger.net>
References: <445BB22B.30505@lwfinger.net> <Pine.LNX.4.58.0605052256570.26787@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:16812 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751778AbWEEVXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 17:23:08 -0400
To: Uli Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org,
	Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Harald Welte <laforge@gnumonks.org>,
	Jouni Malinen <jkm@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>
In-Reply-To: <Pine.LNX.4.58.0605052256570.26787@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uli Kunitz wrote:
> Larry Finger wrote:
> 
>> * A new routine (ieee80211_init_geo ?) will be written to be called by the
>> driver to load the geo structure into the kernel. Information passed to the
>> daemon will be the country code in ASCII and whether the interface is to be
>> used indoors or outdoors.
> 
> Would it be possible to support the regulatory domain codes as
> used in the outdated table 105 in Corrigendum 1 for 802.11b? The
> ZD1211 EEPROM contains only this code. An easy translation
> function would be sufficient. Maybe the group codes could be
> misused for it.

That certainly shouldn't be any difficulty. It could be done in the ZD1211 driver before it calls 
the ieee80211_init_geo routine, or it could be done in the regulatory daemon. I assume that the 
EEPROM contains X'10' for FCC regulations, X'31' for Spain, etc.

Larry
