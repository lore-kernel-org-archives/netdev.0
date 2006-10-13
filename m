From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 0/5] d80211.h bitfield removal
Date: Fri, 13 Oct 2006 12:20:45 -0700
Message-ID: <20061013192045.GA18694@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:23786 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751832AbWJMTUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 15:20:51 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Continue d80211 bitfield removal.  In general, compilers have
difficulty generating efficient code for bitfields.  This patchset
removes all bitfields from include/net/d80211.h (except for the xr and
Super A/G fields which are completely removed by previous patches).

I converted the 1 bit bitfields into a bit in a u32 flags structure
member.  Larger bitfields I converted into their u8/u16/whatever
equivalent.

This should be a no-op from a functionality standpoint.

-David

--
