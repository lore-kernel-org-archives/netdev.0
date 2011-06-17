From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: teach the tun/tap driver to support netpoll
Date: Thu, 16 Jun 2011 23:53:34 -0400 (EDT)
Message-ID: <20110616.235334.1805823535607900944.davem@davemloft.net>
References: <1308151501-8434-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, riel@redhat.com, maxk@qualcomm.com,
	amwang@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732Ab1FQDyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:54:47 -0400
In-Reply-To: <1308151501-8434-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 15 Jun 2011 11:25:01 -0400

> Commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093 changed the behavior of slave
> devices in regards to netpoll.  Specifically it created a mutually exclusive
> relationship between being a slave and a netpoll-capable device.  This creates
> problems for KVM because guests relied on needing netconsole active on a slave
> device to a bridge.  Ideally libvirtd could just attach netconsole to the bridge
> device instead, but thats currently infeasible, because while the bridge device
> supports netpoll, it requires that all slave interface also support it, but the
> tun/tap driver currently does not.  The most direct solution is to teach tun/tap
> to support netpoll, which is implemented by the patch below.
> 
> I've not tested this yet, but its pretty straightforward.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Rik van Riel <riel@redhat.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Maxim Krasnyansky <maxk@qualcomm.com>
> CC: Cong Wang <amwang@redhat.com>
> CC: "David S. Miller" <davem@davemloft.net>

Applied, thanks Neil.
