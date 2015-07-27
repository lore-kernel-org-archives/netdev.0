From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Retrieve tunnel metadata when
 receiving from vport-netdev
Date: Sun, 26 Jul 2015 21:19:33 -0700 (PDT)
Message-ID: <20150726.211933.409072959161623165.davem@davemloft.net>
References: <f91747edf4825bd5b6641c5c815d0e20f59b7a3a.1437649446.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbG0ETd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 00:19:33 -0400
In-Reply-To: <f91747edf4825bd5b6641c5c815d0e20f59b7a3a.1437649446.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 23 Jul 2015 13:04:44 +0200

> Retrieve the tunnel metadata for packets received by a net_device and
> provide it to ovs_vport_receive() for flow key extraction.
> 
> [This hunk was in the GRE patch in the initial series and missed the
>  cut for the initial submission for merging.]
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
