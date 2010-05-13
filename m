From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 13 May 2010 22:49:00 +0200
Message-ID: <4BEC65BC.5040208@trash.net>
References: <20100513201714.25579.53530.stgit@savbu-pc100.cisco.com> <20100513201720.25579.51230.stgit@savbu-pc100.cisco.com> <4BEC63DB.2090306@trash.net> <20100513204614.GB30483@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, arnd@arndb.de
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62253 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759465Ab0EMUtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 16:49:01 -0400
In-Reply-To: <20100513204614.GB30483@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Wright wrote:
> * Patrick McHardy (kaber@trash.net) wrote:
>>> +	} else  {
>>> +		err = rtnl_vf_port_fill_nest(skb, dev, -1);
>> What does -1 mean?
> 
> It means no VFs.  Could be made a macro/enum constant

Why call rtnl_vg_port_fill_nest at all in that case? It even
calls the ndo_get_vf_port() callback.
