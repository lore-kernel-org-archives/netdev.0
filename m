From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: allow wireless vlan interface to have
	sameMAC an AP interface
Date: Tue, 10 Oct 2006 12:50:27 +0200
Message-ID: <1160477427.2727.8.camel@ux156>
References: <20061003181118.537800000@devicescape.com>
	 <20061003181233.GE19403@devicescape.com>
	 <1160343128.4701.6.camel@johannes.berg>
	 <20061009213807.GH26254@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:8917 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751555AbWJJKti
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 06:49:38 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061009213807.GH26254@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-09 at 14:38 -0700, Jouni Malinen wrote:

> Yes, I just merged in support for this (dynamic VLANs) into hostapd.
> RADIUS Access-Accept is used select VLAN is being used and the STA is
> bound at that point to another virtual interface, if needed.

Different question. How do broadcasts to a vlan interface work? Are they
rewritten to unicasts to all vlan stations? You obviously can't get
perfect separation anyway since it all travels over the shared medium
and stations can always sniff the packets, but ...

johannes
