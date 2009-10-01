From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32-rc1] net: VMware virtual Ethernet NIC driver:
 vmxnet3
Date: Wed, 30 Sep 2009 19:51:23 -0700 (PDT)
Message-ID: <20090930.195123.33813752.davem@davemloft.net>
References: <alpine.LRH.2.00.0909301432410.8073@localhost.localdomain>
	<20090930173923.4520716a@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, anthony@codemonkey.ws, chrisw@sous-sol.org,
	greg@kroah.com, akpm@linux-foundation.org,
	virtualization@lists.linux-foundation.org, pv-drivers@vmware.com
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755506AbZJACvG@vger.kernel.org>
In-Reply-To: <20090930173923.4520716a@s6510>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 30 Sep 2009 17:39:23 -0700

> Why not use NETIF_F_LRO and ethtool to control LRO support?

In fact, you must, in order to handle bridging and routing
correctly.

Bridging and routing is illegal with LRO enabled, so the kernel
automatically issues the necessary ethtool commands to disable
LRO in the relevant devices.

Therefore you must support the ethtool LRO operation in order to
support LRO at all.
