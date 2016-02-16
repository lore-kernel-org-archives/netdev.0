From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for
 RNDIS_STATUS_NETWORK_CHANGE
Date: Tue, 16 Feb 2016 15:28:27 -0500 (EST)
Message-ID: <20160216.152827.2202202588726087877.davem@davemloft.net>
References: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
	<20160209.050438.1204672612521151525.davem@davemloft.net>
	<BN1PR0301MB07700DD7E77C7B71C650B37DCAD60@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	vkuznets@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN1PR0301MB07700DD7E77C7B71C650B37DCAD60@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 9 Feb 2016 15:31:34 +0000

> 1) I share your concern as well. Is there a universal way to immediately trigger 
> DHCP renew of all current and future daemons with a single event from kernel? 
> If not, can we put the delay (RNDIS_STATUS_NETWORK_CHANGE only) into a 
> tunable variable of this driver?
> 
> 2) We used to have the call_usermodehelper "/etc/init.d/network restart" to 
> trigger DHCP renew. In commit 27a70af3f4, Vitaly has replaced it with the current 
> code that updates the link status with at least 2 seconds interval, so that the 
> "link_watch infrastructure" can send notification out. link_watch infrastructure 
> only sends one notification per second.

If the daemon is waiting for the link state change properly, there should be
no delay necessary at all.
