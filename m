From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [clarification request] ieee80211_tx_control.pkt_type
Date: Fri, 18 Aug 2006 16:50:48 +0200
Message-ID: <1155912648.5671.3.camel@ux156>
References: <1155901317.22520.2.camel@ux156>
	 <20060818143321.GA23446@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Barber <simon@devicescape.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:5326 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030454AbWHROu4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 10:50:56 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060818143321.GA23446@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-18 at 07:33 -0700, Jouni Malinen wrote:

> Some hardware designs require this configuration for TX frames. It is
> used to select whether some of the fields are being filled in hardware
> (e.g., timestamp for Probe Response). 

Ah ok, timestamp makes sense.

> This would only be needed for AP
> mode and IBSS (adhoc), so it is possible that not all low-level dirvers
> have yet been implemented to support such operation.

Right.

> This pkt_type was added at generic 802.11 layer in order to avoid
> forcing the low-level driver to even look at the 802.11 header when
> queuing the frame for transmission. Taken into account how simple
> operation it is to get the type and subtype from the frame control
> field, this tx ctrl pkt_type could be removed, if desired. However, it
> was added there for a reason.

No, that's ok, I was just wondering why it is there at all.

Thanks for clarifying,
johannes
