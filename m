From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: extending  ndo_add_rx_vxlan_port
Date: Sun, 27 Oct 2013 17:21:51 +0200
Message-ID: <526D2F8F.1070204@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yan Burman <yanb@mellanox.com>, netdev <netdev@vger.kernel.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:39777 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753368Ab3J0PXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 11:23:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

So with commit 53cf527513eed6e7170e9dceacd198f9267171b0 "vxlan: Notify 
drivers for listening UDP port changes" drivers that have HW offloads 
for vxlan can be notified on which UDP port to listen. Taking this 
further, some HW may need to know the multicast address and/or the VNID 
used by the vxlan instance/s set above them. In that respect, do we 
prefer to extend ndo_add_rx_vxlan_port() or introduce new ndo?

Or.
