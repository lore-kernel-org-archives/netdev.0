From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 12:33:24 -0700 (PDT)
Message-ID: <20100721.123324.237334251.davem@davemloft.net>
References: <20100721.114851.200597269.davem@davemloft.net>
	<20100721.115023.69942880.davem@davemloft.net>
	<43F901BD926A4E43B106BF17856F0755F1846247@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, shemminger@vyatta.com, andy@greyhouse.net,
	harald@redhat.com, bhutchings@solarflare.com, sassmann@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49413
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758793Ab0GUTdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 15:33:08 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F1846247@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Wed, 21 Jul 2010 12:02:17 -0700

>>From: David Miller <davem@davemloft.net>
>>Date: Wed, 21 Jul 2010 11:48:51 -0700 (PDT)
>>
>>> You could do things like have the PF controller use the root
>>filesystem
>>> ID label to construct the VF's MAC address, or something like that.
>>
>>And here I of course mean the root filesystem of the guest the VF will
>>be given to.
> 
> I suppose you could do that but then the VM is going to have to be
> allowed to set its own MAC address.  There is a lot of opposition
> and concern about allowing VMs to set their own MAC address.

Why would that be necessary?  The host with the PF creating the guest
has access to the "device" and thus the root filesystem of the guest,
and thus could pull in the root filesystem "key" and instantiate the
VF's MAC before booting the guest.

That was the idea, the control node sets up the VF MAC before the guest
boots or can have access to the VF device.

This is completely agnostic of migration or anything like that.  The
procedure for setting the VF MAC is always the same.
