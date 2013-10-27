From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: extending  ndo_add_rx_vxlan_port
Date: Sun, 27 Oct 2013 10:25:13 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1310271017120.19783@intel.com>
References: <526D2F8F.1070204@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60060 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983Ab3J0RIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 13:08:47 -0400
In-Reply-To: <526D2F8F.1070204@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 27 Oct 2013, Or Gerlitz wrote:

> Hi,
> 
> So with commit 53cf527513eed6e7170e9dceacd198f9267171b0 "vxlan: Notify drivers
> for listening UDP port changes" drivers that have HW offloads for vxlan can be
> notified on which UDP port to listen. Taking this further, some HW may need to
> know the multicast address and/or the VNID used by the vxlan instance/s set
> above them. In that respect, do we prefer to extend ndo_add_rx_vxlan_port() or
> introduce new ndo?
> 
> Or.
> 

The way this patch works is to notify the drivers when a VXLAN UDP port 
comes up or down. This way drivers do not need to do any sort of accounting. As 
long as this remains, it sounds fine to me to extend the existing ndo. If 
by extedning it, drivers now have to keep track of the udp ports so they 
can determine if a notification is for a new port or not, I would much 
rather go for introducing a new ndo.

Joseph
