From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: use dev_port to identify ports
Date: Sun, 22 Jun 2014 17:23:07 -0700 (PDT)
Message-ID: <20140622.172307.2305001882391366010.davem@davemloft.net>
References: <1403354888-15600-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com,
	linux-kernel@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403354888-15600-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Sat, 21 Jun 2014 09:48:08 -0300

> Commit 3f85944fe207d0225ef21a2c0951d4946fc9a95d ("net: Add sysfs file
> for port number") introduce dev_port to network devices. cxgb4 adapters
> have multiple ports on the same PCI function, and used dev_id to
> identify those ports. That use was removed by commit
> 8c367fcbe6549195d2eb11e62bea233f811aad41 ("cxgb4: Do not set
> net_device::dev_id to VI index"), since dev_id should be used only when
> devices share the same MAC address.
> 
> Using dev_port for cxgb4 allows different ports on the same PCI function
> to be identified.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

You've made exactly zero effort to explain why the IPV6 issue carefully
explained in commit 8c367fcbe6549195d2eb11e62bea233f811aad41 no longer
applies.

As far as I can tell, it absolutely does, and therefore this change
here should not be made.

I'm not applying this patch, sorry.
