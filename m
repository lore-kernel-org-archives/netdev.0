From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next 1/1] netns: IPv6 address labels per namespace.
Date: Wed, 28 May 2008 21:05:14 +0900 (JST)
Message-ID: <20080528.210514.118764806.yoshfuji@linux-ipv6.org>
References: <20080527144050.754524679@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53513 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbYE1MEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 08:04:44 -0400
In-Reply-To: <20080527144050.754524679@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080527144050.754524679@theryb.frec.bull.fr> (at Tue, 27 May 2008 16:40:42 +0200), Benjamin Thery <benjamin.thery@bull.net> says:

> This patch makes IPv6 address labels per network namespace.
> It keeps the global label tables, ip6addrlbl_table, but 
> adds a 'net' member to each ip6addrlbl_entry.
> This new member is taken into account when matching labels.

Could you please eliminate penalty without namespece
like dev_net() etc.?

--yoshfuji
