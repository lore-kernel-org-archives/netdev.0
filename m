From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Tue, 10 Jun 2008 09:14:09 +0200
Message-ID: <484E29C1.2010302@trash.net>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080527141346.12851.2280.stgit@localhost.localdomain> <4847E75D.9080609@trash.net> <D5C1322C3E673F459512FB59E0DDC3290538B15D@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57555 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbYFJHOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 03:14:12 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290538B15D@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
>>> +struct dcbnl_genl_ops {
>>> +	u8   (*getstate)(struct net_device *);
>>> +	void (*setstate)(struct net_device *, u8);
>>> +	void (*getpermhwaddr)(struct net_device *, u8 *);
>> "getpermhwaddr" doesn't seem to belong in this interface but 
>> in rtnetlink and/or ethtool instead.
> 
> This was a feature in ethtool, but it was removed at some point.  I can
> add it to rtnetlink though if people think it'll be useful to have.

I think thats a better idea than to put it in a private
driver interface.


