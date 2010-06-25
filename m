From: Sebastien Jan <s-jan@ti.com>
Subject: Re: [PATCH] smsc95xx: Add module parameter to override MAC address
Date: Fri, 25 Jun 2010 08:55:41 +0200
Message-ID: <4C2452ED.8020307@ti.com>
References: <1277367254-9345-1-git-send-email-s-jan@ti.com> <20100625012520.GA12650@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56885 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474Ab0FYG5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 02:57:43 -0400
In-Reply-To: <20100625012520.GA12650@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2010 03:25 AM, Simon Horman wrote:
> On Thu, Jun 24, 2010 at 10:14:14AM +0200, Sebastien Jan wrote:
>> Define a new module parameter 'macaddr' to override the MAC address
>> fetched either from eeprom, or randomly generated.
>>
>> The expected MAC address shall be in the 01:23:45:67:89:AB format.
> 
> I'm confused as to why this is desirable when the mac address
> can already be configured after module insertion via
> smsc95xx_netdev_ops.eth_mac_addr().

For example for booting over NFS using a pre-defined MAC address, with 
a minimal setup (no initrd). Or is there another way to force a MAC
address for this use-case?
