From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate
 modules
Date: Tue, 28 Oct 2014 14:43:44 -0400 (EDT)
Message-ID: <20141028.144344.398016097830457432.davem@davemloft.net>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbaJ1Snq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 14:43:46 -0400
In-Reply-To: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Oct 2014 17:29:06 +0200

> The internal and netdev vport remain part of openvswitch.ko. Encap
> vports including vxlan, gre, and geneve can be built as separate
> modules and are loaded on demand. Modules can be unloaded after use.
> Datapath ports keep a reference to the vport module during their
> lifetime.
> 
> Allows to remove the error prone maintenance of the global list
> vport_ops_list.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks a lot Thomas.
