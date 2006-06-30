From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 39 of 39] IB/ipath - use streaming copy in RDMA
 interrupt handler to reduce packet loss
Date: Thu, 29 Jun 2006 17:47:38 -0700 (PDT)
Message-ID: <20060629.174738.85688575.davem@davemloft.net>
References: <44A47042.8060203@hp.com>
	<20060629.173206.48800902.davem@davemloft.net>
	<44A473D5.70809@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bos@pathscale.com, akpm@osdl.org, rdreier@cisco.com,
	mst@mellanox.co.il, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26066
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964824AbWF3Ark (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:47:40 -0400
To: rick.jones2@hp.com
In-Reply-To: <44A473D5.70809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 29 Jun 2006 17:44:05 -0700

> Then is prefetching in memcpy really that important to them.

Not really, the thread just blocks while waiting for memory.
On stores they do a cacheline fill optimization similar to
the powerpc.

> Relying on PCI-X devices to issue multiple requests then?

Perhaps :)
