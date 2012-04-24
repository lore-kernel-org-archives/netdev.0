From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [net-next PATCH] net: dcb: add CEE notify calls
Date: Tue, 24 Apr 2012 15:56:19 +0300
Message-ID: <1335272179.15423.23.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <20120420194923.8103.54825.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	amirv@dev.mellanox.co.il
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2292 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449Ab2DXKxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2012 06:53:45 -0400
In-Reply-To: <20120420194923.8103.54825.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2012-04-20 at 12:49 -0700, John Fastabend wrote:
> This adds code to trigger CEE events when an APP change or setall
> command is made from user space. This simplifies user space code
> significantly by creating a single interface to listen on that
> works with both firmware and userland agents.
> 
> And if we end up with multiple agents this keeps every thing in
> sync userland agents, firmware agents, and kernel notifier consumers.
> 
> For an example agent that listens for these events see:
> 
> https://github.com/jrfastab/cgdcbxd
> 
> cgdcbxd is a daemon used to monitor DCB netlink events and manage
> the net_prio control group sub-system.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 

Acked-by: Shmulik Ravid <shmulikr@broadcom.com>

Thanks John,

Shmulik 
