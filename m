From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Mon, 25 Oct 2010 16:25:35 -0700 (PDT)
Message-ID: <20101025.162535.226782713.davem@davemloft.net>
References: <20101025111235.GA2024@emulex.com>
	<20101025.120943.189699949.davem@davemloft.net>
	<20101025223853.GD15074@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: somnath.kotur@emulex.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20101025223853.GD15074@solarflare.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 25 Oct 2010 23:38:53 +0100

> David Miller wrote:
>> From: Somnath Kotur <somnath.kotur@emulex.com>
>> Date: Mon, 25 Oct 2010 16:42:35 +0530
>> 
>> > By default, be2net uses MSIx wherever possible.
>> > Adding a module parameter to use INTx for users who do not want to use MSIx.
>> > 
>> > Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
>> 
>> Either add a new ethtool flag, or use the PCI subsystem facilities
>> for tweaking things to implement this.
>>
>> Do not use a module option, otherwise every other networking driver
>> author will get the same "cool" idea, give the module option
>> different names, and the resulting user experience is terrible.
> 
> This has already happened, sadly.  So far as I can see it's mostly done
> to allow users to work around systems with broken MSIs; I'm not aware of
> any other reason to prefer legacy interrupts.  However, the PCI subsystem
> already implements a blacklist and a kernel parameter for disabling MSIs
> on these systems.

The PCI subsystem bits I'm totally fine with.

But in the drivers themselves, that's what I don't want.
