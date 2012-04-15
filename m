From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vxge: Add MODULE_FIRMWARE
Date: Sun, 15 Apr 2012 12:33:06 -0400 (EDT)
Message-ID: <20120415.123306.2132770845160354506.davem@davemloft.net>
References: <1334262882-96973-1-git-send-email-tim.gardner@canonical.com>
	<1334498215.3209.4.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tim.gardner@canonical.com, linux-kernel@vger.kernel.org,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334498215.3209.4.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 15 Apr 2012 14:56:55 +0100

> Also: this driver's behaviour of automatically updating flash without
> any confirmation seems quite dangerous.  The driver also isn't usable
> after it performs such an update:
> 
> 	printk(KERN_NOTICE "Upgrade of firmware successful!  Adapter must be "
> 	       "hard reset before using, thus requiring a system reboot or a "
> 	       "hotplug event.\n");
> 
> So what is the point of integrating firmware update into the driver at
> all?

This is beyond terrible.
