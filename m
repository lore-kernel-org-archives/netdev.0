From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: New commands to configure IOV features
Date: Tue, 17 Jul 2012 15:08:45 -0600
Message-ID: <5005D45D.1040302@genband.com>
References: <4FA7AF62.8000405@broadcom.com> <20120507081634.000003f8.gregory.v.rose@intel.com> <4FE9A963.7020602@broadcom.com> <20120626101903.0000791c@unknown> <1341859155.2535.43.camel@bwh-desktop.uk.solarflarecom.com> <4FFB4985.3040507@genband.com> <5003DC9B.8000706@broadcom.com> <5005BD00.4090106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-pci@vger.kernel.org
To: Don Dutile <ddutile@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:57694 "EHLO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374Ab2GQVI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 17:08:58 -0400
In-Reply-To: <5005BD00.4090106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2012 01:29 PM, Don Dutile wrote:

> WRT SRIOV-nic devices, the thinking goes that protocol-level
> parameters associated with VFs should use protocol-specific interfaces,
> e.g., ethtool, ip link set, etc. for Ethernet VFs.
> Thus, the various protocol control functions/tools should
> be used to control VF parameters, as one would for a physical device
> of that protocol/class.

It seems to me that the mere act of creating one or more VFs is 
something generic, applicable to all devices that are capable of it. 
The details of configuring those VFs can then be handled by 
protocol-specific interfaces.

I'm not too worried about the exact mechanism of doing it, as long as 
it's ultimately scriptable--that is, if it's a C API then it would be 
appreciated if there was a standard tool to call that implements it. 
 From that perspective a sysfs-based interface is ideal since it is 
directly scriptable.

Chris
