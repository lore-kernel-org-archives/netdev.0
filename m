From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc6] net-next: Add multiqueue support to vmxnet3
 driver
Date: Fri, 15 Oct 2010 09:23:27 -0700 (PDT)
Message-ID: <20101015.092327.193701886.davem@davemloft.net>
References: <20101013145732.7d69d0f3@nehalam>
	<1287073868.2258.13.camel@achroite.uk.solarflarecom.com>
	<89E2752CFA8EC044846EB8499819134102BF0F3B1D@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <89E2752CFA8EC044846EB8499819134102BF0F3B1D@EXCH-MBX-4.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 14 Oct 2010 16:31:35 -0700

> Okay. It would be best to keep module parameters to dictate number
> of queues till ethtool commands to do so become available/easy to
> use (command to change number of tx queues do not exist).

No, because then you can never remove these knobs, they must stay
forever.

And also then every other driver developer can make the same
argument.  And then we have private knobs in every driver and
the user experience is a complete disaster.

Instead, the onus is on you to help get the ethtool interfaces
completed so your driver can provide the functionality it
wants.

Not the other way around (add crap first, use the proper interface
later whenever someone else gets around to it).

Thanks.
