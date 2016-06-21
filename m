From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Tue, 21 Jun 2016 04:34:31 -0400 (EDT)
Message-ID: <20160621.043431.177352816188322653.davem@davemloft.net>
References: <20160617.202641.1821023739498595024.davem@davemloft.net>
	<CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
	<34f19f9c-221b-78f0-3989-9384e0d22e54@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, aduyck@mirantis.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, jesse@kernel.org,
	eugenia@mellanox.com, jbenc@redhat.com, alexander.duyck@gmail.com,
	saeedm@mellanox.com, ariel.elior@qlogic.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com
To: hannes@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbcFUIgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 04:36:11 -0400
In-Reply-To: <34f19f9c-221b-78f0-3989-9384e0d22e54@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@redhat.com>
Date: Mon, 20 Jun 2016 11:11:32 -0700

> I am not sure if this is necessary. The devices actually having the
> ndo-ops, used to configure offloading, should only be visible inside one
> namespace. If those ndo-ops actually have side effects on other
> namespaces, they violate the contract and should be removed from the
> driver. :/

This is most if not all drivers right now, to the best of my
understanding.
