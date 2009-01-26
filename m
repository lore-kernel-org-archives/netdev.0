From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 0/2 2.6.30] cxgb3 - notify iWARP of chip resets
Date: Mon, 26 Jan 2009 09:57:54 -0800
Message-ID: <adaeiyqymot.fsf@cisco.com>
References: <497DF609.9000600@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Steve Wise <swise@opengridcomputing.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:9543 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272AbZAZR55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:57:57 -0500
In-Reply-To: <497DF609.9000600@chelsio.com> (Divy Le Ray's message of "Mon, 26
	Jan 2009 09:42:33 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > I'm submitting 2 patches against cxgb3 and iw_cxgb3 respectively.
 > They are built against net-next-2.6.
 > The first patch adds a notification mechanism to cxgb3 to alert
 > the upper layer drivers (iWARP and iSCSI) of a chip reset.
 > 
 > The second patch adds the handler for such an event in the iWARP driver.
 > 
 > Since the second patch depends on the first one, I submit them together,
 > even though the second patch should be submitted against Roland's tree.

simplest thing is for Dave to merge both, and I'm fine with that.

 - R.
