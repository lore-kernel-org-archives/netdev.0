From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] powerpc: Add TBI PHY node to first MDIO bus
Date: Wed, 7 Dec 2011 15:52:10 -0600
Message-ID: <8E6B8366-A254-4528-8327-91710BD0C68D@kernel.crashing.org>
References: <1323287457-6085-1-git-send-email-afleming@freescale.com> <20111207.150208.588206951117780997.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59936 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756618Ab1LGVwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 16:52:12 -0500
In-Reply-To: <20111207.150208.588206951117780997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 7, 2011, at 2:02 PM, David Miller wrote:

> From: Andy Fleming <afleming@freescale.com>
> Date: Wed, 7 Dec 2011 13:50:57 -0600
> 
>> Systems which use the fsl_pq_mdio driver need to specify an
>> address for TBI PHY transactions such that the address does
>> not conflict with any PHYs on the bus (all transactions to
>> that address are directed to the onboard TBI PHY). The driver
>> used to scan for a free address if no address was specified,
>> however this ran into issues when the PHY Lib was fixed so
>> that all MDIO transactions were protected by a mutex. As it
>> is, the code was meant to serve as a transitional tool until
>> the device trees were all updated to specify the TBI address.
>> 
>> The best fix for the mutex issue was to remove the scanning code,
>> but it turns out some of the newer SoCs have started to omit
>> the tbi-phy node when SGMII is not being used. As such, these
>> devices will now fail unless we add a tbi-phy node to the first
>> mdio controller.
>> 
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> ---
>> 
>> This requires fsl_pq_mdio: Clean up tbi address configuration from
>> the net tree in order to achieve its full effect.
>> 
>> This needs to go into 3.2.
> 
> I'm fine if the powerpc tree takes this one:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Will pull in via PPC tree.

- k
