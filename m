From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/10] dpaa_eth: add configurable bpool thresholds
Date: Sun, 26 Jul 2015 16:35:20 -0700 (PDT)
Message-ID: <20150726.163520.846046458508685868.davem@davemloft.net>
References: <1437581806-17420-3-git-send-email-madalin.bucur@freescale.com>
	<1437587228.20787.26.camel@perches.com>
	<BL2PR03MB545AA0E6D98232FF43B6CE9E6810@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	scottwood@freescale.com, Igal.Liberman@freescale.com,
	ppc@mindchasers.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BL2PR03MB545AA0E6D98232FF43B6CE9E6810@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Date: Fri, 24 Jul 2015 15:49:39 +0000

>> -----Original Message-----
>> From: Joe Perches [mailto:joe@perches.com]
>> On Wed, 2015-07-22 at 19:16 +0300, Madalin Bucur wrote:
>> > Allow the user to tweak the refill threshold and the total number
>> > of buffers in the buffer pool. The provided values are for one CPU.
>> 
>> Any value in making these module parameters instead?
> 
> I expect one would (hardly ever) change these to improve some corner
> cases then use them with the new values. It may help in the tuning process
> but afterwards the bloat to the bootcmd would probably be  a nuisance.

I think these should be controlled by the existing ethtool infrastructure.

Neither the Kconfig mechanism nor module parameters are appropriate, at all.
