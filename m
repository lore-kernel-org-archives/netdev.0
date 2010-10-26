From: <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Mon, 25 Oct 2010 22:24:39 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63A00DC7EA5@EXMAIL.ad.emulex.com>
References: <20101025111235.GA2024@emulex.com>
	<20101025.120943.189699949.davem@davemloft.net>
	<20101025223853.GD15074@solarflare.com>,<20101025.162535.226782713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:1203 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752417Ab0JZF1D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 01:27:03 -0400
In-Reply-To: <20101025.162535.226782713.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
         Could you pls ignore this patch and apply the next patch in the series ?
 ( PATCH 2/2]  be2net: Schedule/Destroy worker thread in probe()/remove() rather than open()/close()

Thanks
Som
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Tuesday, October 26, 2010 4:55 AM
To: bhutchings@solarflare.com
Cc: Kotur, Somnath; netdev@vger.kernel.org; linux-pci@vger.kernel.org
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx instead of MSI-X

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
