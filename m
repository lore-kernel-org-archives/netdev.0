From: David Miller <davem@davemloft.net>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 15:33:35 -0500 (EST)
Message-ID: <20160112.153335.213439668062764562.davem@davemloft.net>
References: <20151229152208.GA22423@oracle.com>
	<5695106D.8040909@list.ru>
	<20160112144725.GA30240@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stsp@list.ru, netdev@vger.kernel.org, alexander.duyck@gmail.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047AbcALUdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:33:37 -0500
In-Reply-To: <20160112144725.GA30240@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 12 Jan 2016 09:47:25 -0500

> On (01/12/16 17:40), Stas Sergeev wrote:
>> Updated testing results:
>> After I disabled shared_media not only for "all", but
>> also for _all_ interfaces individually, the problem seem to
>> have stopped. So thanks for these hints.
>> Now, as the media is actually really shared (same NIC/cable),
>> I just wonder what's going on here.
> 
> I dont know the history of the shared_media tunable (or
> the rationale behind the default) - I was just reading out the
> code - perhaps someone on the list who has the history can share 
> the motivation behind this tunable.

Most of the choices for defaults for ipv4 routing and ARP behavior
are motivated by two things:

1) host based addressing model

2) increasing the chance of successful communication with peers
