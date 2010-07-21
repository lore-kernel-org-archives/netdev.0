From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 11:48:51 -0700 (PDT)
Message-ID: <20100721.114851.200597269.davem@davemloft.net>
References: <20100721.103249.107094774.davem@davemloft.net>
	<201007211129.48288.leedom@chelsio.com>
	<43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, shemminger@vyatta.com, andy@greyhouse.net,
	harald@redhat.com, bhutchings@solarflare.com, sassmann@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37858
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756708Ab0GUSse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 14:48:34 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Wed, 21 Jul 2010 11:43:19 -0700

> Intel's view of things is that we don't use persistent MAC addresses
> in our VFs because the MAC address belongs to the VM and when it
> migrates it's going to want to use another VF with the same MAC
> address.  If they're persistent I'm wondering how that can be done.
> 
> This discussion has come about because some folks want to use the VF
> in the Host VMM.  The original design goal for Intel was that VFs
> would be assigned to VMs and that VMM vendors would want to assign
> MAC addresses with their own assigned OUI's.

If the VM itself is the "physical entity" of the system, the logical
conclusion I come to is that some kind of key should be obtained
through the VM to uniquely give the device a persistent MAC.

You could do things like have the PF controller use the root filesystem
ID label to construct the VF's MAC address, or something like that.
