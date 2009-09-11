From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: Use Intel OUI for VF MAC addresses
Date: Fri, 11 Sep 2009 12:15:42 -0700 (PDT)
Message-ID: <20090911.121542.45333246.davem@davemloft.net>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	<20090910190703.25d14533@nehalam>
	<1252638163.4355.35.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55826
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756044AbZIKTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:15:26 -0400
In-Reply-To: <1252638163.4355.35.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 10 Sep 2009 20:02:43 -0700

> On Thu, 2009-09-10 at 19:07 -0700, Stephen Hemminger wrote:
>> On Thu, 10 Sep 2009 18:48:27 -0700
>> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>> > From: Gregory Rose <gregory.v.rose@intel.com>
>> > This patch changes the default VF MAC address generation to use an Intel
>> > Organizational Unit Identifier (OUI), instead of a fully randomized
>> > Ethernet address.  This is to help prevent accidental MAC address
>> > collisions.
> 
> I think this not a very good idea.
> 
>> How can probability of collision be lower when the address space
>> is smaller? If you are going to use Intel OUI, then you should constrain
>> the selection to a portion of that space that is not being used
>> by other hardware. I.e if you know Intel assigns addresses to their
>> devices in ranges, choose a range that is not in use.
> 
> Some other possibilities might be:

I also completely agree that this patch is not a wise move.
