From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH 1/1] bna: Generic Netlink Interface to collect FW
 trace
Date: Tue, 26 Apr 2011 18:59:17 -0700
Message-ID: <20110426185917.3d033636@nehalam>
References: <1303869117-780-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<huangj@brocade.com>, <amathur@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41244 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755458Ab1D0B7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 21:59:20 -0400
In-Reply-To: <1303869117-780-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Apr 2011 18:51:57 -0700
Rasesh Mody <rmody@brocade.com> wrote:

> This is a RFC patch to Brocade BNA 10G Ethernet driver. It adds the generic
> netlink communication interface to the BNA driver to collect firmware traces
> using the in-kernel generic netlink infrastructure. The driver uses the
> "dumpit" handler provided by the generic netlink layer to accomplish this. The
> driver can extend this interface later if required. 
> 
> As of today, there seems to be no standard mechanism to collect debug
> information such as firmware trace for a given hardware. Generic Netlinki seems
> to provide a suitable option to do the same, without any further
> addition/modification to the existing kernel implementation.
> 
> This is a RFC patch inviting suggestions/opinions for improvement/modification
> and requesting consideration for possible inclusion in net-next tree.
> 
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Seems like a lot of work for a debug interface. What about debugfs?
Or is that out of favor now, I can never keep track...

-- 
