From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [net-next v2 28/71] 8139*/atp/r8169/sc92031: Move the Realtek
 drivers
Date: Mon, 01 Aug 2011 23:21:20 -0400
Message-ID: <4E376D30.6050406@pobox.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com> <1312082850-24914-29-git-send-email-jeffrey.t.kirsher@intel.com> <1312244694.2591.42.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Donald Becker <becker@scyld.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62579 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab1HBDVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 23:21:24 -0400
Received: by qwk3 with SMTP id 3so3113928qwk.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 20:21:23 -0700 (PDT)
In-Reply-To: <1312244694.2591.42.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2011 08:24 PM, Ben Hutchings wrote:
> On Sat, 2011-07-30 at 20:26 -0700, Jeff Kirsher wrote:
>> Move the Realtek drivers into drivers/net/ethernet/realtek/ and make
>> the necessary Kconfig and Makefile changes.
> [...]
>
> Does it really make sense to move the pci-skeleton driver?  Although it
> includes hardware access specific to RTL8139 chips, that's not really
> the point of it.

Indeed.  pci-skeleton was simply intended to illustrate a clean driver 
for a simple DMA-driven NIC.

Honestly, it's so outdated now that deletion would be a better course.

	Jeff



