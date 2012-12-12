From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv3 iproute2] add DOVE extensions for iproute2
Date: Wed, 12 Dec 2012 10:03:24 -0800
Message-ID: <20121212100324.76b8d511@nehalam.linuxnetplumber.net>
References: <201212121756.qBCHtOfn021538@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35261 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754734Ab2LLSEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 13:04:40 -0500
In-Reply-To: <201212121756.qBCHtOfn021538@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 12:55:24 -0500
David L Stevens <dlstevens@us.ibm.com> wrote:

> 	This patch adds a new flag to iproute2 for vxlan devices to enable
> DOVE features. It also adds support for L2 and L3 switch lookup miss
> netlink messages to "ip monitor".
> 
> Changes since v2: fix merge conflict
> Changes since v1:
> 	- split "dove" flag into separate feature flags:
> 		- "proxy" for ARP reduction
> 		- "rsc" for route short circuiting
> 		- "l2miss" for L2 switch miss notifications
> 		- "l3miss" for L3 switch miss notifications
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Applied, after mollifying the git whitespace complaints.
