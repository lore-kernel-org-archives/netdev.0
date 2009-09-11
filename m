From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next PATCH] igb: Use Intel OUI for VF MAC addresses
Date: Thu, 10 Sep 2009 19:07:03 -0700
Message-ID: <20090910190703.25d14533@nehalam>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32950 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbZIKCHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 22:07:09 -0400
In-Reply-To: <20090911014757.19631.66570.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Sep 2009 18:48:27 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Gregory Rose <gregory.v.rose@intel.com>
> 
> This patch changes the default VF MAC address generation to use an Intel
> Organizational Unit Identifier (OUI), instead of a fully randomized
> Ethernet address.  This is to help prevent accidental MAC address
> collisions.

How can probability of collision be lower when the address space
is smaller? If you are going to use Intel OUI, then you should constrain
the selection to a portion of that space that is not being used
by other hardware. I.e if you know Intel assigns addresses to their
devices in ranges, choose a range that is not in use.
