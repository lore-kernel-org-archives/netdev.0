From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] e1000: Fix for e1000 kills IPMI on a tagged
 vlan.
Date: Tue, 01 Sep 2009 17:43:36 -0700 (PDT)
Message-ID: <20090901.174336.138535279.davem@davemloft.net>
References: <20090901001250.31418.88709.stgit@localhost.localdomain>
	<alpine.LNX.1.10.0909010247460.5651@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, david.graham@intel.com
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40449
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755413AbZIBAnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:43:22 -0400
In-Reply-To: <alpine.LNX.1.10.0909010247460.5651@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Oledzki <ole@ans.pl>
Date: Tue, 1 Sep 2009 02:53:29 +0200 (CEST)

> 
> 
> On Mon, 31 Aug 2009, Jeff Kirsher wrote:
> 
>> From: Graham, David <david.graham@intel.com>
> 
> <CUT>
>> A complete solution to this issue would require further driver
>> changes.
>> The driver would need to discover if (and which) management VLANs are
>> active before enabling VLAN filtering, so that it could ensure that
>> the
>> managed VLANs are included in the VLAN filter table. This discovery
>> requires that the BMC identifies its VLAN in registers accessible
>> to the driver, and at least on Dell PE2850 systems the BMC does not
>> identify its VLAN to allow such discovery. Intel is pursuing this
>> issue
>> with the BMC vendor.
>>
>> Signed-off-by: Dave Graham <david.graham@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Applied, thanks.
